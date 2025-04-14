import SwiftUI

struct ImageCropView: View {
    let image: UIImage
    let onComplete: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var cropRect: CGRect
    @State private var showCroppedPreview = false
    @State private var croppedImage: UIImage?
    @State private var imageSize: CGSize = .zero
    @State private var imageFrame: CGRect = .zero
    @State private var isDragging = false
    
    // Define Neon Purple Color
    let neonPurple = Color(red: 0.6, green: 0.0, blue: 1.0)
    let dragSensitivityFactor: CGFloat = 0.2 // Further reduced sensitivity
    
    init(image: UIImage, onComplete: @escaping (UIImage) -> Void) {
        self.image = image
        self.onComplete = onComplete
        // Start with a centered rectangle crop frame
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let width = screenWidth * 0.8
        let height = screenHeight * 0.4
        let x = (screenWidth - width) / 2
        let y = (screenHeight - height) / 2
        _cropRect = State(initialValue: CGRect(x: x, y: y, width: width, height: height))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                if showCroppedPreview, let croppedImage = croppedImage {
                    // Preview of cropped image
                    VStack {
                        Image(uiImage: croppedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                        
                        HStack(spacing: 40) {
                            Button(action: {
                                showCroppedPreview = false
                            }) {
                                Text("Recrop")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.gray.opacity(0.5))
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                onComplete(croppedImage)
                                dismiss()
                            }) {
                                Text("Use Photo")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.purple)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                } else {
                    // --- Image View (now directly in ZStack background) --- 
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .background(GeometryReader { imageGeometry in
                            Color.clear.onAppear {
                                imageSize = imageGeometry.size
                                // Calculate initial image frame relative to the ZStack
                                imageFrame = imageGeometry.frame(in: .named("ZStackCoordSpace")) 
                            }
                        })
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // --- Crop Frame Overlay --- 
                    ZStack {
                        // Semi-transparent overlay
                        Rectangle()
                            .fill(Color.black.opacity(0.5))
                            .mask(
                                Rectangle()
                                    .overlay(
                                        Rectangle()
                                            .frame(width: cropRect.width, height: cropRect.height)
                                            .position(x: cropRect.midX, y: cropRect.midY)
                                            .blendMode(.destinationOut)
                                    )
                            )
                        
                        // --- Text Label positioned above cropRect --- 
                        Text("Crop only one problem")
                            .font(.headline)
                            .foregroundColor(neonPurple)
                            .padding(4)
                            .background(Color.black.opacity(0.5)) // Optional background for readability
                            .cornerRadius(5)
                            .position(x: cropRect.midX, y: cropRect.minY - 25) // Position above

                        // Crop rectangle outline
                        Rectangle()
                            .stroke(Color.white, lineWidth: 1)
                            .frame(width: cropRect.width, height: cropRect.height)
                            .position(x: cropRect.midX, y: cropRect.midY)
                        
                        // Corner controls
                        Group {
                            // Top Left
                            CornerControl(color: neonPurple)
                                .position(x: cropRect.minX, y: cropRect.minY)
                                .gesture(DragGesture()
                                    .onChanged { value in
                                        let newX = min(cropRect.maxX - 100, value.location.x)
                                        let newY = min(cropRect.maxY - 100, value.location.y)
                                        let deltaW = cropRect.minX - newX
                                        let deltaH = cropRect.minY - newY
                                        cropRect = CGRect(
                                            x: newX,
                                            y: newY,
                                            width: cropRect.width + deltaW,
                                            height: cropRect.height + deltaH
                                        )
                                    }
                                )
                            
                            // Top Right
                            CornerControl(color: neonPurple)
                                .position(x: cropRect.maxX, y: cropRect.minY)
                                .gesture(DragGesture()
                                    .onChanged { value in
                                        let newWidth = max(100, value.location.x - cropRect.minX)
                                        let newY = min(cropRect.maxY - 100, value.location.y)
                                        let deltaH = cropRect.minY - newY
                                        cropRect = CGRect(
                                            x: cropRect.minX,
                                            y: newY,
                                            width: newWidth,
                                            height: cropRect.height + deltaH
                                        )
                                    }
                                )
                            
                            // Bottom Left
                            CornerControl(color: neonPurple)
                                .position(x: cropRect.minX, y: cropRect.maxY)
                                .gesture(DragGesture()
                                    .onChanged { value in
                                        let newX = min(cropRect.maxX - 100, value.location.x)
                                        let newHeight = max(100, value.location.y - cropRect.minY)
                                        let deltaW = cropRect.minX - newX
                                        cropRect = CGRect(
                                            x: newX,
                                            y: cropRect.minY,
                                            width: cropRect.width + deltaW,
                                            height: newHeight
                                        )
                                    }
                                )
                            
                            // Bottom Right
                            CornerControl(color: neonPurple)
                                .position(x: cropRect.maxX, y: cropRect.maxY)
                                .gesture(DragGesture()
                                    .onChanged { value in
                                        let newWidth = max(100, value.location.x - cropRect.minX)
                                        let newHeight = max(100, value.location.y - cropRect.minY)
                                        cropRect = CGRect(
                                            x: cropRect.minX,
                                            y: cropRect.minY,
                                            width: newWidth,
                                            height: newHeight
                                        )
                                    }
                                )
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !isDragging { 
                                    if cropRect.contains(value.startLocation) { 
                                         isDragging = true 
                                    }
                                } else { 
                                    let adjustedTranslationX = value.translation.width * dragSensitivityFactor
                                    let adjustedTranslationY = value.translation.height * dragSensitivityFactor
                                    
                                    let potentialX = cropRect.origin.x + adjustedTranslationX
                                    let potentialY = cropRect.origin.y + adjustedTranslationY
                                    
                                    // --- Boundary Check Example (relative to imageFrame) ---
                                    // Ensure the new rect doesn't go outside the displayed image bounds
                                    let clampedX = max(imageFrame.minX, min(potentialX, imageFrame.maxX - cropRect.width))
                                    let clampedY = max(imageFrame.minY, min(potentialY, imageFrame.maxY - cropRect.height))
                                    
                                    cropRect.origin.x = clampedX
                                    cropRect.origin.y = clampedY
                                }
                            }
                            .onEnded { _ in
                                isDragging = false 
                            }
                    )
                    
                    // --- Bottom Controls Overlay --- 
                    VStack {
                        Spacer()
                        HStack(spacing: 40) {
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                            
                            Button(action: {
                                if let cropped = cropImage() {
                                    croppedImage = cropped
                                    showCroppedPreview = true
                                }
                            }) {
                                Image(systemName: "checkmark")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.purple) // Keep original purple for button
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .coordinateSpace(name: "ZStackCoordSpace") // Add coordinate space name
        }
    }
    
    private func cropImage() -> UIImage? {
        // Calculate the scale between the display size and actual image size
        let scale = image.size.width / imageFrame.width
        
        // Convert crop rect to image coordinates
        let normalizedX = (cropRect.minX - imageFrame.minX) * scale
        let normalizedY = (cropRect.minY - imageFrame.minY) * scale
        let normalizedWidth = cropRect.width * scale
        let normalizedHeight = cropRect.height * scale
        
        let cropZone = CGRect(x: normalizedX,
                            y: normalizedY,
                            width: normalizedWidth,
                            height: normalizedHeight)
        
        // Ensure we're within the image bounds
        let validCropZone = cropZone.intersection(CGRect(origin: .zero, size: image.size))
        
        guard let cgImage = image.cgImage?.cropping(to: validCropZone) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

struct CornerControl: View {
    let color: Color

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 20, height: 20)
            .shadow(color: .black.opacity(0.3), radius: 3)
    }
} 