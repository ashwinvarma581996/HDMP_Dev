/*
Created By : Rajrishi Kaushik
Date : 18/05/2021
Description : This class is Wraps the Api's responses from IN System.
*/

public class B2B_INCatalogWrapper {
    @AuraEnabled public List<CalalogData> ProductCategories;
    @AuraEnabled public List<CalalogData> Products; 
    @AuraEnabled public List<CalalogData> Doors;
    @AuraEnabled public List<CalalogData> Years;
    @AuraEnabled public List<Catalog> Catalogs;
    @AuraEnabled public List<SelectedProduct> SelectedProducts;
    @AuraEnabled public List<CalalogData> Origins;
    @AuraEnabled public List<CalalogData> Areas;
    @AuraEnabled public List<CalalogData> Grades;
    @AuraEnabled public List<CalalogData> Transmissions;
    @AuraEnabled public List<CalalogData> ColorLabels;
    @AuraEnabled public List<CalalogData> ColorNames;
    @AuraEnabled public List<Sections> Sections;
    @AuraEnabled public List<IllustrationGroup> IllustrationGroups;
    @AuraEnabled public List<HotSpot> HotSpots;
    @AuraEnabled public List<Part> Parts;
    @AuraEnabled public List<ImageIllustrationGroupDetail> ImageIllustrationGroupDetails;
    @AuraEnabled public List<ProductDealerPrice> ProductDealerPrice;
    
    public static B2B_INCatalogWrapper parse(String json){
        return (B2B_INCatalogWrapper) System.JSON.deserialize(json, B2B_INCatalogWrapper.class);
    }
    
    public class SelectedProduct{
        public Integer ProductID;
    }
    public class Catalog{
        public Integer CatalogID;
    }
    public class CalalogData {
        public Integer ID;
        public String Description;
    } 
    
    public class Sections {
        public Integer ID;
        public String Description;
        public String SectionURL;
        public Integer ImageSize;
    }
    
    public class IllustrationGroup {
        public Integer ID;
        public String Code;    
        public String Description;
        public Integer SectionID;
        public String SectionDescription;
        public Integer IllustrationGroupImageID;
        public Boolean SerialNumberFlag;
        public Boolean ChartFlag;
        public String Subject;
        public Integer ThumbnailHeight;
        public Integer ThumbnailWidth;
        public String Code2;
        public String ThumbnailURL;
    }
    
    public class HotSpot {
        public Integer ItemSequenceID;
        public String IllustrationReferenceCode;
        public Integer XPosition;
        public Integer YPosition;
    }
    
    public class Part {
        @AuraEnabled public Integer PartID;
        @AuraEnabled public String IllustrationReferenceCode;
        @AuraEnabled public String QuantityRequired;
        @AuraEnabled public String EngineFrameTransmissionTypeCode;
        @AuraEnabled public String LoUnVisSerialGroup;
        @AuraEnabled public String HighUnVisSerialGroup;
        @AuraEnabled public String HondaCode;
        @AuraEnabled public String PartNumber;
        @AuraEnabled public String PartDescription;
        @AuraEnabled public String PartControlCode;
        @AuraEnabled public String SRACode;
        @AuraEnabled public String MostForwardSupersession;
        @AuraEnabled public String ForwardSupersession;
        @AuraEnabled public String BackwardSupersession;
        @AuraEnabled public String MultiOrderQuantity;
        @AuraEnabled public String DealerNetPriceAmount;
        @AuraEnabled public String SuggestedRetailPriceAmount;
        @AuraEnabled public String CoreCostAmount;
        @AuraEnabled public String PriceChangeFlag;
        @AuraEnabled public String PartStatusCode;
        @AuraEnabled public String VDFlag;
        @AuraEnabled public String WholsaleCompFlag;
        @AuraEnabled public String PartModificationCode;
        @AuraEnabled public String NATABCQuantityCode;
        @AuraEnabled public String PartSizeCode;
        @AuraEnabled public String CRSShipCode;
        @AuraEnabled public String CommonPartFlag;
        @AuraEnabled public String Height;
        @AuraEnabled public String Length;
        @AuraEnabled public Integer GradeID;
        @AuraEnabled public String GradeDescription;
        @AuraEnabled public Integer AreaID;
        @AuraEnabled public String AreaDescription;
        @AuraEnabled public Integer OriginID;
        @AuraEnabled public String OriginDescription;
        @AuraEnabled public Integer TransmissionID;
        @AuraEnabled public String TransmissionDescription;
        @AuraEnabled public Integer ColorLabelID;
        @AuraEnabled public String ColorLabelDescription;
        @AuraEnabled public String IllustrationReferenceCodeOrderBy;
        @AuraEnabled public String IllustrationReferenceCode2;
        @AuraEnabled public String PartDescriptionMasterFile;       
        @AuraEnabled public String FunctionCode;
        @AuraEnabled public String IsMatched;
    }
    
    public class ImageIllustrationGroupDetail {
        public Integer ID;
        public Integer CatalogID;
        public String Code;
        public Integer PixelHeight;
        public Integer PixelWidth;
        public String IllustrationURL;
    }
    
     public class ProductDealerPrice {
        public Integer DealerNo;
        public Integer DivisionId;
        public String PartNumber;
        public String AccessoryCode;
    }
}