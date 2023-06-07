@isTest
global class OwnConsumerProfileService_MockService implements WebServiceMock {
	
	global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
  
	/*
	<soapenv:Envelopexmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"xmlns:xsd="http://www.w3.org/2001/XMLSchema"xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
		<soapenv:Header>
				<h:hondaMsgHeaderxmlns:h="http://www.honda.com/header">
						<messageId>207e19bb-189b-4079-b6e2-0ef259bed267</messageId>
						<siteId>7a075db5b4b04c04afdc0b75fc135a80</siteId>
						<businessId>HONDALINKCONNECT</businessId>
						<collectedTimestamp>2020-11-30T09:55:29+00:00</collectedTimestamp>
				</h:hondaMsgHeader>
		</soapenv:Header>
		<soapenv:Body>
            <consumer:ConsumerProfileRespxmlns:consumer="http://ConsumerProfileMsg">
            <consumer:ConsumerProfiles>
                <consumer:CID>219216723</consumer:CID>
                <consumer:FirstName>KETI</consumer:FirstName>
                <consumer:MiddleInitial/>
                <consumer:LastName>JANI</consumer:LastName>
                <consumer:CustomerType>Individual</consumer:CustomerType>
                <consumer:LastDateUpdated>2021-02-28T21:57:01-08:00</consumer:LastDateUpdated>
                <consumer:DateCreated>2020-12-21T00:54:37-08:00</consumer:DateCreated>
                <consumer:Addresses>
                    <consumer:AddressLine>140MAINSTAPT2</consumer:AddressLine>
                    <consumer:City>PEABODY</consumer:City><consumer:State>MA</consumer:State>
                    <consumer:Zip>01960</consumer:Zip><consumer:Plus4>5766</consumer:Plus4>
                </consumer:Addresses>
                <consumer:Addresses>
                    <consumer:AddressLine>140MAIN2FLST</consumer:AddressLine>
                    <consumer:City>PEABODY</consumer:City>
                    <consumer:State>MA</consumer:State>
                    <consumer:Zip>01960</consumer:Zip>
                    <consumer:Plus4>0000</consumer:Plus4>
                </consumer:Addresses>
                <consumer:Addresses>
                    <consumer:AddressLine>140MAINST#2FL</consumer:AddressLine>
                    <consumer:City>PEABODY</consumer:City>
                    <consumer:State>MA</consumer:State>
                    <consumer:Zip>01960</consumer:Zip>
                    <consumer:Plus4>5765</consumer:Plus4>
                </consumer:Addresses>
                <consumer:Addresses>
                    <consumer:AddressLine>N/A</consumer:AddressLine>
                    <consumer:City>PEABODY</consumer:City>
                    <consumer:State>MA</consumer:State>
                    <consumer:Zip>01960</consumer:Zip>
                    <consumer:Plus4>0000</consumer:Plus4>
                </consumer:Addresses>
                <consumer:Addresses>
                    <consumer:AddressLine>140MAINST</consumer:AddressLine>
                    <consumer:City>PEABODY</consumer:City>
                    <consumer:State>MA</consumer:State>
                    <consumer:Zip>01960</consumer:Zip>
                    <consumer:Plus4>5765</consumer:Plus4>
                </consumer:Addresses>
                <consumer:Emails>NOEMAIL@GMAIL.COM</consumer:Emails>
                <consumer:Emails>KETIJANI20@GMAIL.COM</consumer:Emails>
                <consumer:Emails>JKETI@HOTMAIL.COM</consumer:Emails>
                <consumer:Dealers>
                    <consumer:DealerNumber>207075</consumer:DealerNumber>
                    <consumer:DealerName>HONDANORTH</consumer:DealerName>
                    <consumer:Division>Honda</consumer:Division>
                    <consumer:Relation>Geographic</consumer:Relation>
                </consumer:Dealers>
                <consumer:Dealers>
                    <consumer:DealerNumber>251192</consumer:DealerNumber>
                    <consumer:DealerName>ACURAOFPEABODY</consumer:DealerName>
                    <consumer:Division>Acura</consumer:Division>
                    <consumer:Relation>Geographic</consumer:Relation>
                </consumer:Dealers>
                <consumer:Dealers>
                    <consumer:DealerNumber>208133</consumer:DealerNumber>
                    <consumer:DealerName>KELLYHONDA</consumer:DealerName>
                    <consumer:ProductID>3CZRU6H36MM708621</consumer:ProductID>
                    <consumer:Division>Honda</consumer:Division>
                    <consumer:Model>HR-V</consumer:Model>
                    <consumer:Year>2021</consumer:Year>
                    <consumer:Relation>SALES</consumer:Relation>
                    <consumer:LastDateOfTrx>2020-12-26Z</consumer:LastDateOfTrx>
                </consumer:Dealers>
                <consumer:Dealers>
                    <consumer:DealerNumber>208133</consumer:DealerNumber>
                    <consumer:DealerName>KELLYHONDA</consumer:DealerName>
                    <consumer:ProductID>3CZRU6H36MM708621</consumer:ProductID>
                    <consumer:Division>Honda</consumer:Division>
                    <consumer:Model>HR-V</consumer:Model>
                    <consumer:Year>2021</consumer:Year>
                    <consumer:Relation>SERVICE</consumer:Relation>
                    <consumer:LastDateOfTrx>2021-03-23Z</consumer:LastDateOfTrx>
                </consumer:Dealers>
                <consumer:CurrentlyOwnedProducts>
                    <consumer:ProductID>VINNUMBER00000003</consumer:ProductID>
                    <consumer:Division>Honda</consumer:Division>
                    <consumer:Model>TestModel3</consumer:Model>
                    <consumer:Year>2021</consumer:Year>
                    <consumer:IsCurrentOwner>Y</consumer:IsCurrentOwner>
                    <consumer:Relation>Owner</consumer:Relation>
                    <consumer:PurchaseDate>2020-12-26Z</consumer:PurchaseDate>
                    <consumer:IsPurchasedNew>Y</consumer:IsPurchasedNew>
                    <consumer:SellingDealer>208133</consumer:SellingDealer>
                    <consumer:SellingDealerName>KELLYHONDA</consumer:SellingDealerName>
                </consumer:CurrentlyOwnedProducts>
                <consumer:CIDLevelMsgCode>25</consumer:CIDLevelMsgCode>
                <consumer:CIDLevelMsgText>AIRDATABASEDOWN</consumer:CIDLevelMsgText>
			</consumer:ConsumerProfiles>
            	<consumer:MsgCode>00</consumer:MsgCode>
				<consumer:MsgText>SUCCESS</consumer:MsgText>
            </consumer:ConsumerProfileResp>
		</soapenv:Body>
	</soapenv:Envelope>';
	*/
    
	OwnConsumerProfileService.OwnedProductInfo opiAcura = new OwnConsumerProfileService.OwnedProductInfo();
	opiAcura.Division = 'Acura';
	opiAcura.ProductID ='00000000000000022';
	OwnConsumerProfileService.OwnedProductInfo opiHonda = new OwnConsumerProfileService.OwnedProductInfo();
	opiHonda.Division = 'Honda';
	opiHonda.ProductID ='VINNUMBER00000003';
	OwnConsumerProfileService.ServicedProductInfo cspAcura = new OwnConsumerProfileService.ServicedProductInfo();
	cspAcura.Division = 'Acura';
	cspAcura.ProductID ='VINNUMBER00000077';
	OwnConsumerProfileService.ServicedProductInfo cspHonda = new OwnConsumerProfileService.ServicedProductInfo();
	cspHonda.Division = 'Honda';
    cspHonda.ProductID ='00000000000000333';

    OwnConsumerProfileService.OwnedProductInfo[] opi = new OwnConsumerProfileService.OwnedProductInfo[]{opiHonda,opiAcura};
	OwnConsumerProfileService.ServicedProductInfo[] csp = new OwnConsumerProfileService.ServicedProductInfo[]{cspHonda,cspAcura};
	
	OwnConsumerProfileService.DealerInfo  dealerInfo = new OwnConsumerProfileService.DealerInfo();
    dealerInfo.Division = 'Acura';
    OwnConsumerProfileService.ConsumerProfile cp = new OwnConsumerProfileService.ConsumerProfile();
	cp.FirstName = 'Bobby';
    cp.CurrentlyOwnedProducts = opi;
	cp.CurrentlyServicedProducts = csp;
    cp.Dealers = new List<OwnConsumerProfileService.DealerInfo>{dealerInfo};
    OwnConsumerProfileService.ConsumerProfile[] l = new OwnConsumerProfileService.ConsumerProfile[]{cp};
    OwnConsumerProfileService.ConsumerProfileResp a = new OwnConsumerProfileService.ConsumerProfileResp();
               a.ConsumerProfiles = l;
	OwnConsumerProfileService d = new OwnConsumerProfileService();


	Map<String, OwnConsumerProfileService.ConsumerProfileResp> m1 = new Map<String,OwnConsumerProfileService.ConsumerProfileResp>();
   
    /*
     * Test Classes
     */
               
    OwnConsumerProfileService.ConsumerProductInfo cpi = new OwnConsumerProfileService.ConsumerProductInfo();
	OwnConsumerProfileService.ConsumerDetailsForRadioNavi cdfrn = new OwnConsumerProfileService.ConsumerDetailsForRadioNavi();
    OwnConsumerProfileService.Address_Out ao = new OwnConsumerProfileService.Address_Out();
    OwnConsumerProfileService.ConsumerProductsInfoReq cpir = new OwnConsumerProfileService.ConsumerProductsInfoReq();
    OwnConsumerProfileService.SegmentationInfo si = new OwnConsumerProfileService.SegmentationInfo();
    OwnConsumerProfileService.VINDealerInfo vdi = new OwnConsumerProfileService.VINDealerInfo();
	OwnConsumerProfileService.CohortInfo ci = new OwnConsumerProfileService.CohortInfo();
	OwnConsumerProfileService.Phone_out po = new OwnConsumerProfileService.Phone_Out();
    OwnConsumerProfileService.VINsDealerInfoReq vdirq = new OwnConsumerProfileService.VINsDealerInfoReq(); 
    OwnConsumerProfileService.ConsumerInfo cio = new OwnConsumerProfileService.ConsumerInfo();
    OwnConsumerProfileService.VINsDealerInfoResp vdirp = new OwnConsumerProfileService.VINsDealerInfoResp();
    OwnConsumerProfileService.DealerInfo di = new OwnConsumerProfileService.DealerInfo();
    OwnConsumerProfileService.ConsumerProductsInfoResp cpirp = new OwnConsumerProfileService.ConsumerProductsInfoResp();
               
    response.put('response_x', a); 
   }
}