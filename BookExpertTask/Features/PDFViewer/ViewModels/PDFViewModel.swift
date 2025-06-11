import Foundation
import PDFKit
import SwiftUI

@MainActor
class PDFViewModel: ObservableObject {
    @Published var pdfDocument: PDFDocument?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var currentPageIndex: Int = 0
    
     var pdfURL = URL(string: Constants.API.pdfURL)!
    
    // MARK: - PDF Information
    
    var currentPageNumber: Int {
        currentPageIndex + 1
    }
    
    var totalPages: Int {
        return pdfDocument?.pageCount ?? 0
    }
    
    var pageLabel: String {
        return "Page \(currentPageNumber) of \(totalPages)"
    }
    
    init() {
        loadPDF()
    }
    
    func loadPDF() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: pdfURL)
                if let document = PDFDocument(data: data) {
                    self.pdfDocument = document
                    self.currentPageIndex = 0
                } else {
                    throw NSError(domain: "PDFError",
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Failed to load PDF document"])
                }
            } catch {
                self.error = error
            }
            
            isLoading = false
        }
    }
    
    func refreshPDF() {
        loadPDF()
    }
    
    // MARK: - PDF Navigation
    
    func goToNextPage() {
        guard currentPageIndex + 1 < totalPages else {
            return
        }
        currentPageIndex += 1
    }
    
    func goToPreviousPage() {
        guard currentPageIndex > 0 else {
            return
        }
        currentPageIndex -= 1
    }
    
    func goToPage(_ pageNumber: Int) {
        guard pageNumber >= 0,
              pageNumber < totalPages else {
            return
        }
        currentPageIndex = pageNumber
    }
    
    func updateCurrentPage(_ page: PDFPage) {
        if let document = pdfDocument {
            let index = document.index(for: page)
            currentPageIndex = index
        }
    }
} 
