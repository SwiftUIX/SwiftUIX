//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || targetEnvironment(macCatalyst)
@testable import SwiftUIX
import XCTest

@MainActor
final class ImagePickerTests: XCTestCase {
    func testSavedPhotosAlbumSourceType() {
        guard UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else {
            return
        }
        
        let image = ReferenceBox()
        let picker = ImagePicker(image: Binding(get: { image.image }, set: { image.image = $0 }))
            .sourceType(.savedPhotosAlbum)
        let controller = UIImagePickerController()
        
        picker.applyInitialPickerConfiguration(controller)
        
        XCTAssertEqual(controller.sourceType, .savedPhotosAlbum)
    }
    
    func testUnavailableCameraLeavesPhotoLibrary() {
        guard !UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return
        }
        
        let image = ReferenceBox()
        let picker = ImagePicker(image: Binding(get: { image.image }, set: { image.image = $0 }))
            .sourceType(.camera)
            .cameraDevice(.front)
        let controller = UIImagePickerController()
        
        picker.applyInitialPickerConfiguration(controller)
        
        XCTAssertEqual(controller.sourceType, .photoLibrary)
    }
    
    func testAvailableCameraSetsSourceTypeAndCameraDevice() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return
        }
        
        let frontImage = ReferenceBox()
        let frontPicker = ImagePicker(image: Binding(get: { frontImage.image }, set: { frontImage.image = $0 }))
            .sourceType(.camera)
            .cameraDevice(.front)
        let frontController = UIImagePickerController()
        
        frontPicker.applyInitialPickerConfiguration(frontController)
        
        XCTAssertEqual(frontController.sourceType, .camera)
        
        if frontController.sourceType == .camera {
            XCTAssertEqual(frontController.cameraDevice, .front)
        }
        
        let rearImage = ReferenceBox()
        let rearPicker = ImagePicker(image: Binding(get: { rearImage.image }, set: { rearImage.image = $0 }))
            .sourceType(.camera)
        let rearController = UIImagePickerController()
        
        rearPicker.applyInitialPickerConfiguration(rearController)
        
        XCTAssertEqual(rearController.sourceType, .camera)
        
        if rearController.sourceType == .camera {
            XCTAssertEqual(rearController.cameraDevice, .rear)
        }
    }
    
    func testPhotoLibrarySourceType() {
        let image = ReferenceBox()
        let picker = ImagePicker(image: Binding(get: { image.image }, set: { image.image = $0 }))
            .sourceType(.photoLibrary)
        let controller = UIImagePickerController()
        
        picker.applyInitialPickerConfiguration(controller)
        
        XCTAssertEqual(controller.sourceType, .photoLibrary)
    }
    
    private final class ReferenceBox {
        var image: AppKitOrUIKitImage?
    }
}
#endif
