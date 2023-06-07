/**
 * @description       : EshoppyOutboundSpecialRequestWrapper
 * @author            : Rama Iyer
 * @group             : Offer Management Outbound Integration Specials Wrapper
 * @last modified on  : 05-17-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class EshoppyOutboundSpecialRequestWrapper {
    public cls_Special Specials;
    public List<cls_Attributes> Attribute;
    
	public class cls_Special {
        public String SpecialId;
        public string OfferIdentifier;
        //public String Action;
        public String AddlInfoUrl;
        public String BannerDiscCompetModel;
        public String BannerDiscPrefix;	
		public String BannerDisclaimer3;	
		public String BannerDisclaimer4;	
		public String BannerDisclaimer5;
        public String BannerImageUrl;	
		public String BannerShortDescription;	
		public String BannerSlsPgmType;	
        public Datetime CreatedDate;
        public String CutlineTxt;	
		public String Descr;
        public String EcmsStatusCd;	
		public Date EffDate;	
		public Date EndDate;
        public Boolean HasSecurityDeposit;	
		public integer HfSelectSort;	
		public String LastUpdatedDate;
        public Decimal SampleApr;
        public string AWebcUrl;
		public Decimal SampleMonthlyPayment;
		public Decimal SampleTerm;	
        public String SlsPgmName;
        public String SpecialRegion;	
		public String SpecialTyp;
        public String TermAndCondTx;
        public Boolean ZeroDue;	
        public Decimal SalesPrgmCd; 
        public String HasRegions; 
        public String SpecialRegionType;
        public boolean IsSplit; 
        public String SplitFromId; 
        public String DivisionCd; 
        public String VehicleTypeCd; 
		//public string SpecialCategory;

		public Decimal TitleIdent;//Added by Rama Iyer 05162023 : OMP-375
        public List<string> SpecialsAttribute;
        public List<string> ZipGroupCoverage;
        public List<cls_SpecialModel> SpecialsModel; 


    }

    public class cls_SpecialModel {
        public String ParentSeriesGroupName;
		public String SeriesGroupName;
		public String ModelGroupName;
		public String TrimGroupName;	
		public String MdlId;	
        public String SlsPgmName;	
		public String ShortDescr;
		public String ShortDisclaimer;
		public String Descr;
		public String TermAndCondTx;
        public String TermMonths;	
		public Decimal BaseMonthlyPayment;
		public Decimal CapitalCostReduction;
		public Decimal NetCapitalCost;
		public String AnnualMiles;
		public Decimal ResidualValue;
		public Decimal TotalMonthlyPayment;
		public Decimal TotalDueAtSigning;
		public Decimal ResidualRate;
		public Decimal MoneyFactor;
        public String ModelYear;	
		public String ImagePath;	
		public String LargeImagePath;
		public Decimal Msrp;	
        public Boolean IsFeatured;	
		public Decimal ModelPosition;	
		public Boolean HasTerms;	
        public String ImageColor;	
		public String ImageSrcName;	
        public Decimal DealerContribution;	
		public Decimal GrossMargin;	
		public Decimal BonusCash1;	
		public Decimal BonusCash2;	
		public Decimal BonusCash3;
		public Decimal BonusCash4;
		public Decimal BonusCash5;
        public Decimal MsrpAdjustedDh; 
        public Decimal SortOrder;	//int
        //public Decimal Invc;
        //Public Decimal AcqFee;
        //public Decimal ResidualValpct;
		//Added on 04/21/2023 - Discussed with Jas and Dennis and Rama Iyer add
		public Decimal AcquisitionFee;
		//Added 05/15/2023 by Rama Iyer to Fix Defect : Lease Title Identifier for Model in Specials Model
		// String TitleIdent;
    }
    
    public class cls_Attributes {
		public String AttributeCd;	
		public String AttributeDescr;	
		public String AttributeImagePath;	
		public String AttributeKeywords;	
		public String AttributeName;	
		public String AttributeUrl;	
		public String XprodDivCd;	
		public String EcmsStatusCd;	
	}
}