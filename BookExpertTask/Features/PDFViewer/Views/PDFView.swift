import SwiftUI
import PDFKit

struct PDFView: View {
    @ObservedObject var viewModel: PDFViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    init(viewModel: PDFViewModel) {
        self.viewModel = viewModel
        viewModel.pdfURL = URL(string: "https://fssservices.bookxpert.co/GeneratedPDF/Companies/nadc/2024-2025/BalanceSheet.pdf")!
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading Balance Sheet...")
                } else if let error = viewModel.error {
                    errorView(error)
                } else if let document = viewModel.pdfDocument {
                    pdfContentView(document)
                } else {
                    Text("Could not load Balance Sheet")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("NADC Balance Sheet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.refreshPDF()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
    
    private func pdfContentView(_ document: PDFDocument) -> some View {
        VStack(spacing: 0) {
            PDFKitView(document: document, viewModel: viewModel)
                .edgesIgnoringSafeArea(.bottom)
            
            if viewModel.totalPages > 1 {
                pdfControls
            }
        }
    }
    
    private var pdfControls: some View {
        HStack(spacing: Constants.UI.defaultSpacing) {
            Button {
                viewModel.goToPreviousPage()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
            }
            .disabled(viewModel.currentPageNumber <= 1)
            
            Text(viewModel.pageLabel)
                .font(.body)
                .foregroundColor(.primary)
            
            Button {
                viewModel.goToNextPage()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title2)
            }
            .disabled(viewModel.currentPageNumber >= viewModel.totalPages)
        }
        .padding()
        .background(colorScheme == .dark ? Color.black : Color.white)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.secondary.opacity(0.2)),
            alignment: .top
        )
    }
    
    private func errorView(_ error: Error) -> some View {
        VStack(spacing: Constants.UI.defaultSpacing) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("Error Loading PDF")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                viewModel.refreshPDF()
            } label: {
                Text("Try Again")
                    .font(.body)
                    .foregroundColor(.white)
                    .frame(width: 200)
                    .frame(height: Constants.UI.defaultButtonHeight)
                    .background(Color.blue)
                    .cornerRadius(Constants.UI.defaultCornerRadius)
            }
            .padding(.top)
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument
    let viewModel: PDFViewModel
    
    func makeUIView(context: Context) -> PDFKit.PDFView {
        let pdfView = PDFKit.PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .horizontal
        pdfView.usePageViewController(true)
        pdfView.delegate = context.coordinator
        
        // Set initial page
        if let page = document.page(at: viewModel.currentPageIndex) {
            pdfView.go(to: page)
        }
        
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFKit.PDFView, context: Context) {
        pdfView.document = document
        
        // Update page if needed
        if let page = document.page(at: viewModel.currentPageIndex) {
            pdfView.go(to: page)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PDFViewDelegate {
        let parent: PDFKitView
        
        init(_ parent: PDFKitView) {
            self.parent = parent
        }
        
        @MainActor
        func pdfViewPageChanged(_ pdfView: PDFKit.PDFView) {
            if let currentPage = pdfView.currentPage {
                parent.viewModel.updateCurrentPage(currentPage)
            }
        }
    }
}

#Preview {
    PDFView(viewModel: PDFViewModel())
}
