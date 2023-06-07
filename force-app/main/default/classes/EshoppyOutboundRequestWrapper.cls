/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-17-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class EshoppyOutboundRequestWrapper{
	public cls_StandardSpecial StandardSpecial;
	public List<cls_Attributes> Attributes;

	public class cls_StandardSpecial {
		public String SalesforceOfferId;
        public String Action;
        public string AWebcUrl;
        public Decimal SalesPrgmCd;
		public String OfferIdentifier;	
		public String StandardSpecialId;
		public String AddlInfoUrl;	
		public String AhfcEndDate;	
		public String AhfcSlsPgmId;	
		public String AhfcStartDate;	
		public String AhmSlsPgmId;	
		public String BannerDiscCompetModel;
		public String BannerDiscPrefix;	
		public String BannerDisclaimer3;	
		public String BannerDisclaimer4;	
		public String BannerDisclaimer5;	
		public String BannerImageUrl;	
		public String BannerShortDescription;	
		public String BannerSlsPgmType;	
		public Decimal BonusBucksAmount;
		public String CreatedDate;	
		public String CutlineTxt;	
		public String Descr;	
		public Decimal DoubleBonusBucksAmount;	
		public String EcmsStatusCd;	
		public String EffDate;	
		public String  EndDate;	//05/16/2023 - Changed for OMP-301
		public Boolean HasSecurityDeposit;	
		public String HfSelectSort;	
		public String LastUpdatedDate;
		public String MinCreditTierCd;
		public String MinCreditTierDescr;
		public Decimal MonthlyApr;	
		public Decimal MonthlyPaymentAmount;	
		public Decimal NoInterestDuration;	
		public Decimal NoPaymentDuration;	
		public Decimal OfferAmount;	
		public Decimal OriginalHighBalanceApr;
        public String IsSplit; 
        public String SplitFromId; 
		public Decimal PromotionApr;	
		public Decimal PromotionDuration;
		public Decimal SampleApr;
		public String SampleMonthlyPayment;
		public Decimal SampleTerm;	
		public String ShortDescr;	
		public String ShortDisclaimer;	
		public String SlsPgmName;	
		public String SlsPgmTypCd;	
		public String SpecialCategory;	
		public String SpecialRegion;	
		public String SpecialTyp;
		public Decimal StandardProgramAprHigh;
		public Decimal StandardProgramAprLow;
		public Datetime StandardProgramDate;	
		public String TermAndCondTx;	
		public Decimal TotalAmountFinanced;	
		public String XprodDivCd;	
		public Boolean ZeroDue;	
		public List<string> Attribute;
		public List<cls_Model> Model;
		public List<cls_Term> Term;
		public List<string> ZipGroupCoverage;

		//Added 05/16/2023 : Rama Iyer - OMP-375 for Standard Lease
		public Decimal TitleIdent;
		
		
	}
	
	public class cls_Model {
		public String ParentSeriesGroupName;	//nvarchar(75)
		public String SeriesGroupName;	//nvarchar(75)
		public String ModelGroupName;	//nvarchar(75)
		public String TrimGroupName;	//nvarchar(75)
		public String MdlId;	//nvarchar(11)
		public String ModelYear;	//nvarchar(4)
		public String ImagePath;	//varchar(256)
		public String LargeImagePath;	//varchar(256)
		public Decimal Msrp;	//decimal(9, 2)
		public Decimal DhCost;	//decimal(9, 2)
		public String ImageColor;	//varchar(50)
		public String ImageSrcName;	//nvarchar(100)
		public String SlsPgmName;	//nvarchar(500)
		public String ShortDescr;	//nvarchar(500)
		public String ShortDisclaimer;	//nvarchar(500)
		public String Descr;	//nvarchar(4000)
		public String TermAndCondTx;	//nvarchar(4000)
		public String TermMonths;	//int
		public Decimal BaseMonthlyPayment;	//decimal(9, 2)
		public Decimal CapitalCostReduction;	//decimal(9, 2)
		public Decimal NetCapitalCost;	//decimal(9, 2)
		public String AnnualMiles;	//int
		public Decimal ResidualValue;	//decimal(9, 2)
		public Decimal TotalMonthlyPayment;	//decimal(9, 2)
		public Decimal TotalDueAtSigning;	//decimal(9, 2)
		public Decimal ResidualRate;	//decimal(4, 2)
		public Decimal MoneyFactor;	//decimal(9, 7)
		public Boolean IsFeatured;	//bit
		public Decimal ModelPosition;	//int
		public Boolean HasTerms;	//bit
		public Decimal SortOrder;	//int
		public Decimal DealerContribution;	//decimal(9, 2)
		public Decimal GrossMargin;	//decimal(38, 6)
		public Decimal BonusCash1;	//decimal(9, 2)
		public Decimal BonusCash2;	//decimal(9, 2)
		public Decimal BonusCash3;	//decimal(9, 2)
		public Decimal BonusCash4;	//decimal(9, 2)
		public Decimal BonusCash5;	//decimal(9, 2)
		public Decimal MsrpAdjustedDh;	//decimal(10, 2)
		public Datetime CreatedDate;	//datetime
		public Datetime LastUpdatedDate;	//datetime
        //public Decimal Invc;
        //Public Decimal AcqFee;
        //public Decimal ResidualValpct;
        //Added 04/21/2023 by Rama Iyer, Confirmed with Dennis and Jas Bawa
		public Decimal AcquisitionFee;


		
	}
	public class cls_Term {
		public Decimal TermMoQyMin;	//int
		public Decimal TermMoQyMax;	//int
		public Decimal IntPt;	//decimal(9, 7)
	}

	public class cls_Attributes {
		public String AttributeCd;	//nvarchar(255)
		public String AttributeDescr;	//nvarchar(500)
		public String AttributeImagePath;	//nvarchar(100)
		public String AttributeKeywords;	//nvarchar(200)
		public String AttributeName;	//nvarchar(50)
		public String AttributeUrl;	//nvarchar(200)
		public String XprodDivCd;	//nvarchar(1)
		public string EcmsStatusCd;
	}
	public static EshoppyOutboundRequestWrapper parse(String json){
		return (EshoppyOutboundRequestWrapper) System.JSON.deserialize(json, EshoppyOutboundRequestWrapper.class);
	}
}