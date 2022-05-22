import UIKit
import AVFoundation

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let appBaseURL = "https://flukeapp.com/"
let appName = "Fluke"


//APIS
let APIGetVersion           = "api/getversion"
let APIRegister             = "api/signup"
let APILogin                = "api/signin"
let APIChangePass           = "api/changepassword"
let APILogout               = "api/logout"
let APIDND                  = "api/updatednd"
let APINearestUser          = "api/getnearbyusers"
let APIEditProfile          = "api/edituserprofile"
let APIGetRandomUser        = "api/getuserforcall"
let APIAddUserCall          = "api/addUserCallLogs"
let APICallHistory          = "api/getUserCallLogs"
let APIOnlienOffline        = "api/updateuseronlinestatus"
let APICountryList          = "api/getalluserscountries"
let APIOtherProfile         = "api/getotheruserprofile"
let APIPurchasePlan         = "api/adduserpurchasedplan"
let APIContactUsMsg         = "api/contactus"

let APIJoinCommunity        = "api/joincommunity"
let APIFeedList             = "api/getfeeds"
let APIAddNewFeed           = "api/addfeed"
let APIEditNewFeed          = "api/editfeed"
let APILikeFeed             = "api/likefeed"
let APIReportFeed           = "api/reportfeed"
let APIAddComment           = "api/addcommentfeed"
let APICommentList          = "api/getfeedcomments"
let APIVerifyUserBymail     = "api/verifyemail"
let APIVerifyUserByImage    = "api/uploadphotoid"

let APIBlockUser            = "api/blockuser"
let APIUnBlockUser          = "api/unblockuser"
let APIBlockedUserList      = "api/getblockeduser"

let APIStaticContent        = "api/getstaticpages"

let APIForgotPass           = "api/forgotpassword"


struct Constant {
    
    static func AppType() -> String { return "iOS"}
    static func NewVerions() -> String { return "New version available"}
    static func EmptyMsg() -> String { return "Please enter message"}
    static func NewVerionsDetsil() -> String { return "Please, update app to new version to continue."}
    
    static func EmptyFirstName() -> String { return "Enter first name"}
    static func EmptyLastName() -> String { return "Enter last name"}
    static func EmptyNewPass() -> String { return "Enter new password"}
    static func EmptyOldPass() -> String { return "Enter old password"}
    static func EmptyCity() -> String { return "Select city"}
    static func EmptyEmail() -> String { return "Enter email"}
    static func EmptyPassword() -> String { return "Enter password"}
    static func EmptyConfirmPassword() -> String { return "Enter confirm password"}
    static func NotMatch() -> String { return "Password and confirm password should be same"}
    static func NotMatchOldPass() -> String { return "New password and confirm password should be same"}
    static func EmptyDOB() -> String { return "Select your birth date"}
    static func EmptyAbout() -> String { return "Enter about you"}
    static func InValidEmail() -> String { return "Enter valid email"}

    static func SelectPrivacy() -> String { return "Please accept privacy policy"}
    static func SelectTerms() -> String { return "Please accept terms & conditions"}
    
    static func EmptyOTP() -> String { return "Enter OTP"}
    static func OTPNotValid() -> String { return "Enter correct OTP"}

    static func BtnYes() -> String { return "Yes"}
    static func BtnNo() -> String { return "No"}
    static func BtnOK() -> String { return "OK"}
    static func TryAgain() -> String { return "Please try again"}
    static func BtnDone() -> String { return "Done"}
    static func BtnCancel() -> String { return "Cancel"}
    static func ChooseOption() -> String { return "Choose option"}
    static func Camera() -> String { return "Camera"}
    static func Gallery() -> String { return "Gallery"}
    static func SureLogout() -> String { return "Are you sure you want to logout?"}
    static func OTPSent() -> String { return "Otp sent successfully"}
    
    static func SelectDOB() -> String { return "Select Your DOB"}
    static func SelectProfilePhoto() -> String { return "Select your wow profile photo"}
    
    struct Gender {
        static func MALE() -> String { return "Male"}
        static func FEMALE() -> String { return "Female"}
        static func OTHER() -> String { return "Both"}
    }
    
    
    struct ChatDialogDetails {
        static func OtherUser() -> String { return "otherUserDetails"}
        static func ChatDialog() -> String { return "chatDialog"}
    }
    
    
}


func IsEmpty(strText: String?) -> Bool {
    
    if(strText == nil) {
        return true
    }
    else if (strText!.trimmingCharacters(in: .whitespaces).isEmpty) {
        return true
    }
    else {
        return false
    }
    
}

func isValidEmail(_ email: String?) -> Bool {
    
    let emailAddress = email?.trimmingCharacters(in: .whitespaces)
    
    if(emailAddress == nil) {
        return false
    }
    else {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailAddress)
    }
}

func setImagefromURL(ivImage: UIImageView, strUrl: String?) {
    
    ivImage.clipsToBounds = true
    
    if(strUrl == nil) {
        ivImage.image = #imageLiteral(resourceName: "PlaceholderUser")
    }
    else {
        let url = URL(string: strUrl!)
        ivImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "PlaceholderUser"), options: .lowPriority, context: nil)
    }
    
}


func UTCToLocal(date:String, currentormate: String, newformate: String) -> String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = currentormate //yyyy-MM-dd hh:mm:ss
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

    let dt = dateFormatter.date(from: date)
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = newformate

    return dateFormatter.string(from: dt!)
}

func UTCToLocal(date:Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormatter.string(from: date)
}

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

func getUserAgeFromDate(strDate: String) -> String {
    let ageComponents = strDate.components(separatedBy: "-")
    let dateDOB = Calendar.current.date(from: DateComponents(year: Int(ageComponents[0]), month: Int(ageComponents[1]), day: Int(ageComponents[2])))!
    return "\(dateDOB.getUserAge) Years"
}

func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
    DispatchQueue.global().async { //1
        let asset = AVAsset(url: url) //2
        let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
        avAssetImageGenerator.appliesPreferredTrackTransform = true //4
        let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
        do {
            let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
            let thumbImage = UIImage(cgImage: cgThumbImage) //7
            DispatchQueue.main.async { //8
                completion(thumbImage) //9
            }
        } catch {
            print(error.localizedDescription) //10
            DispatchQueue.main.async {
                completion(nil) //11
            }
        }
    }
}

extension Date {
   var getUserAge: Int {
       return Calendar.current.dateComponents([.year], from: self, to: Date()).year!
   }
}
