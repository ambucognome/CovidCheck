import UIKit
import Photos


class Utilities: NSObject {

    static let shared = Utilities()

   
    //check camera and microphone is granted
    func checkAllPermissionGranted() -> Bool{
        print("photo permission: \(checkPhotoLibraryPermission())")
        if(checkCameraAccess() && checkMicrophoneAccess() && checkPhotoLibraryPermission()){
            return true
        }
        return false
    }


    //    //storage access permission
    func checkPhotoLibraryPermission() -> Bool {
        var isPermited: Bool = false
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            //handle authorized status
            isPermited = true
            break
        case .denied, .restricted :
            //handle denied status
            isPermited = false
            break
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    // as above
                    isPermited = true
                    break
                case .denied, .restricted:
                    // as above
                    isPermited = false
                    break
                case .notDetermined:
                    // won't happen but still
                    isPermited = false
                    break
                case .limited:
                    break
                @unknown default:
                    print("error")
                }
            }
        case .limited: break
            
        @unknown default:
            print("error")
        }

        return isPermited
    }

    //microphone access permission
    func checkMicrophoneAccess() -> Bool {
        var  isparmited = false

        switch AVAudioSession.sharedInstance().recordPermission  {
        case .denied:
            print("Denied, request permission from settings")
        //presentPhoneSettings()
        case .granted:
            print("Authorized, proceed")
            isparmited = true
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { success in
                if success {
                    print("Permission granted, proceed")
                    isparmited = true
                } else {
                    print("Permission denied")
                    isparmited = false
                }
            }
        @unknown default:
            print("error")
        }
        return isparmited
    }


    //camera access permission
    func checkCameraAccess() -> Bool {
        var  isparmited = false
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            print("Denied, request permission from settings")
        //presentPhoneSettings()
        case .restricted:
            print("Restricted, device owner must approve")
            isparmited = false
        case .authorized:
            print("Authorized, proceed")
            isparmited = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    print("Permission granted, proceed")
                    isparmited = true
                } else {
                    print("Permission denied")
                    isparmited = false
                }
            }
        @unknown default:
            print("error")
        }
        return isparmited
    }
}
