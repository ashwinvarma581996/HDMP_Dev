public without sharing class OwnAccountInformationController {
    public static string customerImageDescription = 'Customer uploaded profile image.';

    @AuraEnabled(cacheable=true)
    public static CIAM_Configuration__c getExternalLoginDetails() {
        return CIAM_Configuration__c.getOrgDefaults();
    }

    @AuraEnabled
    public static void saveImage(String userId, String imageName, String imageURL, String imageType){
        // Save a customer-uploaded image as a ContentDocument
        Blob image = System.EncodingUtil.base64Decode(imageURL.remove(imageURL.substring(0, imageURL.indexOf(',')+1)));

        if(!Test.isRunningTest()) {
        // Set photo
        	ConnectApi.Photo photo = ConnectApi.UserProfiles.setPhotoWithAttributes(null, userId, new ConnectApi.PhotoInput(), new ConnectApi.BinaryInput(image, 'image/jpg', 'userImage.jpg'));
        }
    }
}