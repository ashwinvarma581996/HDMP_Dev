public with sharing class OwnEConfigTempData {
   
    public class Powersports
    {
        public string modelId { get; set; }
        public string modelGroupTrim { get; set; } // a.k.a "Trim"
        public string categoryModel { get; set; } // a.k.a "Model"
        public string segmentType { get; set; } // a.k.a - "Type"
        public string year { get; set; }

        public Powersports(String year, String segmentType, String categoryModel, String modelGroupTrim, String modelId)        
        {
            this.year = year;
            this.segmentType = segmentType;
            this.categoryModel = categoryModel;
            this.modelGroupTrim = modelGroupTrim;
            this.modelId = modelId;
        }
    }

    public class PowerEquipments
    {
        public string modelId { get; set; }
        public string modelName { get; set; }
        public string seriesType { get; set; }
        public string productLine { get; set; } // a.k.a "Product"

        public PowerEquipments(String productLine, String seriesType, String modelName, String modelId)
        {
            this.productLine = productLine;
            this.seriesType = seriesType;
            this.modelName = modelName;
            this.modelId = modelId;
        }
    }

    public class Marine
    {
        public string modelId { get; set; }
        public string modelName { get; set; }
        public string outboardModelType { get; set; }
        
        public Marine(String outboardModelType, String modelName, String modelId)
        {
            this.outboardModelType = outboardModelType;
            this.modelName = modelName;
            this.modelId = modelId;
        }
    }

    public class ModelDataWrapper {
        public List<Powersports> powersportsRecords { get; set; }
        public List<PowerEquipments> powerEquipmentRecords { get; set; }
        public List<Marine> marineRecords { get; set; }
        public ModelDataWrapper()
        {
            this.powersportsRecords = new List<Powersports>();
            this.powerEquipmentRecords = new List<PowerEquipments>();
            this.marineRecords = new List<Marine>();
        }        
    }

    public static ModelDataWrapper getPowerModelData()
    {
        ModelDataWrapper modelDataObj = new ModelDataWrapper();
        
        modelDataObj.powersportsRecords.add(new PowerSports('2020','ATV','Rec/Utility','Fourtrax Foreman 4×4','FTF4X4'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','ATV','Rec/Utility','Fourtrax Foreman Rubicon 4×4','FTF4X4RR'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','ATV','Rec/Utility','Fourtrax Rancher','FTFRA'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','ATV','Rec/Utility','Fourtrax Recon','FTFRE'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','ATV','Rec/Utility','Fourtrax Rincon','FRFRI'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','ATV','Sport','TRX250X ','TRX250X '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','ATV','Sport','TRX90X ','TRX90X '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Off-Road','Adventure','Africa Twin ','CRF1000L'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Off-Road','Adventure','Africa Twin Adventure Sports ES','CRF1000LASES'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Off-Road','Adventure','Africa Twin Adventure Sports ES DCT','CRF1000LASESDCT'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Off-Road','Adventure','Africa Twin DCT','CRF1000LDCT'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Off-Road','Competition','CRF150R ','CRF150R '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Off-Road','Competition','CRF150R Expert (Big Wheel)','CRF150REB'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Off-Road','Competition','CRF250R ','CRF250R '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Off-Road','Competition','CRF250RX ','CRF250RX '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Off-Road','Competition','CRF450R ','CRF450R '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Off-Road','Competition','CRF450RWE ','CRF450RWE '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Off-Road','Competition','CRF450RX ','CRF450RX '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Off-Road','Trail','CRF110F ','CRF110F '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Off-Road','Trail','CRF125F ','CRF125F '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Off-Road','Trail','CRF125FB Big Wheel','CRF125FBBW'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Off-Road','Trail','CRF250F ','CRF250F '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Off-Road','Trail','CRF450X ','CRF450X '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Off-Road','Trail','CRF50F ','CRF50F '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Adventure','Africa Twin ','CRF1000L'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Adventure','Africa Twin Adventure Sports ES','CRF1000LASES'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Adventure','Africa Twin Adventure Sports ES DCT','CRF1000LASESDCT'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Adventure','Africa Twin DCT','CRF1000LDCT'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Adventure','CB500X ','CB500X '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Adventure','CB500X ABS','CB500XABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Adventure','NC750X ','NC750X '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Adventure','NC750X DCT ABS','NC750XDCTABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Adventure','XR650L ','XR650L '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Cruiser','Fury ','VT1300CX'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Cruiser','Rebel 300','CMX300'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Cruiser','Rebel 300 ABS','CMX300ABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Cruiser','Rebel 500','CMX500'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Cruiser','Rebel 500 ABS','CMX500ABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Cruiser','Shadow AERO','VT750C'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Cruiser','Shadow AERO ABS','VT750CABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Cruiser','Shadow Phantom','VT750C2B'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Dual Sport','CRF250L ','CRF250L '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Dual Sport','CRF250L ABS','CRF250LABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Dual Sport','CRF250L Rally','CRF250LR'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Dual Sport','CRF250L Rally ABS','CRF250LRABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Dual Sport','CRF450L ','CRF450L '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Dual Sport','XR650L ','XR650L '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','MiniMOTO','Grom ','MSX125 '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','MiniMOTO','Grom ABS','MSX125ABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','MiniMOTO','Monkey ','Monkey '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','MiniMOTO','Monkey ABS','MonkeyABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','MiniMOTO','Super Cub C125 ABS ','C125ABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Neo-Sports Cafe','CB300R ABS','CB300RABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Neo-Sports Cafe','CB650R ABS','CB650RABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Scooter','Metropolitan ','Metropolitan '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Scooter','PCX150 ','PCX150 '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Scooter','PCX150 ABS','PCX150ABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Scooter','Ruckus ','Ruckus '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Supersport','CBR1000RR-R Fireblade SP BSB','CBR1000RRF'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Supersport','CBR300R ','CBR300R '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Supersport','CBR300R ABS','CBR300RABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Supersport','CBR500R ','CBR500R '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Supersport','CBR500R ABS','CBR500RABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Supersport','CBR600RR ','CBR600RR '));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Supersport','CBR600RR ABS','CBR600RRABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Supersport','CBR650R ABS','CBR650RABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Touring','Gold Wing ','GL1800HPN7'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Touring','Gold Wing DCT','GL1800HPN7A'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Touring','Gold Wing Tour','GL1800HPN7T'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Touring','Gold Wing Tour DCT','GL1800HPN7TD'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','Street','Touring','Gold Wing Tour DCT Airbag','GL1800HPN7TAD'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','SXS','Rec/Utility','Pioneer 1000','PNR1000'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','SXS','Rec/Utility','Pioneer 1000 Special Edition','PNR1000SE'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','SXS','Rec/Utility','Pioneer 1000-5','PNR10005'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','SXS','Rec/Utility','Pioneer 1000-5 Special Edition','PNR10005SE'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','SXS','Rec/Utility','Pioneer 500','PNR500'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','SXS','Rec/Utility','Pioneer 520','PNR520'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','SXS','Rec/Utility','Pioneer 700','PNR700'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','SXS','Rec/Utility','Pioneer 700-4','PNR7004'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','SXS','Sport','Talon 1000R','TLN1000R'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','SXS','Sport','Talon 1000R FOX LIVE VALVE','TLN1000RFLV'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','SXS','Sport','Talon 1000R Special Edition','TLN1000RSE'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','SXS','Sport','Talon 1000X','TLN1000X'));
        modelDataObj.powersportsRecords.add(new PowerSports('2020','SXS','Sport','Talon 1000X FOX LIVE VALVE','TLN1000XFLV'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','ATV','Rec/Utility','Fourtrax Foreman 4×4','FTF4X4'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','ATV','Rec/Utility','Fourtrax Foreman Rubicon 4×4','FTF4X4RR'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','ATV','Rec/Utility','Fourtrax Rancher','FTFRA'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','ATV','Rec/Utility','Fourtrax Recon','FTFRE'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','ATV','Rec/Utility','Fourtrax Rincon','FRFRI'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','ATV','Sport','TRX250X ','TRX250X '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','ATV','Sport','TRX90X ','TRX90X '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Off-Road','Adventure','Africa Twin ','CRF1000L'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Off-Road','Adventure','Africa Twin Adventure Sports ES','CRF1000LASES'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Off-Road','Adventure','Africa Twin Adventure Sports ES DCT','CRF1000LASESDCT'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Off-Road','Adventure','Africa Twin DCT','CRF1000LDCT'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Off-Road','Adventure','CRF300L ','CRF300L '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Off-Road','Adventure','CRF300L Rally','CRF300LR'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Off-Road','Competition','CRF150R ','CRF150R '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Off-Road','Competition','CRF150R Expert (Big Wheel)','CRF150REBW'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Off-Road','Competition','CRF250R ','CRF250R '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Off-Road','Competition','CRF250RX ','CRF250RX '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Off-Road','Competition','CRF450R ','CRF450R '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Off-Road','Competition','CRF450RWE ','CRF450RWE '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Off-Road','Competition','CRF450RX ','CRF450RX '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Off-Road','Dual Sport','CRF300L ','CRF300L '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Off-Road','Dual Sport','CRF300L ','CRF300L '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Off-Road','Trail','CRF110F ','CRF110F '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Off-Road','Trail','CRF125F ','CRF125F '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Off-Road','Trail','CRF125FB Big Wheel','CRF125FBBW'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Off-Road','Trail','CRF250F ','CRF250F '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Off-Road','Trail','CRF450X ','CRF450X '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Off-Road','Trail','CRF50F ','CRF50F '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Adventure','Africa Twin ','CRF1000L'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Adventure','Africa Twin Adventure Sports ES','CRF1000LASES'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Adventure','Africa Twin Adventure Sports ES DCT','CRF1000LASESDCT'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Adventure','Africa Twin DCT','CRF1000LDCT'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Adventure','CB500X ABS','CB500XABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Adventure','CRF300 Rally','CRF300R'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Adventure','NC750X ','NC750X '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Adventure','NC750X DCT','NC750XDCT'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Adventure','XR650L ','XR650L '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Cruiser','Fury ','VT1300CX'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Cruiser','Rebel 1100','CMX110'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Cruiser','Rebel 1100 DCT','CMX110DCT'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Cruiser','Rebel 500 ABS SE','CMX500ABSSE'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Cruiser','Rebel 300','CMX300'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Cruiser','Rebel 300 ABS','CMX300ABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Cruiser','Rebel 500','CMX500'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Cruiser','Rebel 500 ABS','CMX500ABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Cruiser','Shadow AERO','VT750C'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Cruiser','Shadow AERO ABS','VT750CABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Cruiser','Shadow Phantom','VT750C2B'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Dual Sport','CRF250L ','CRF250L '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Dual Sport','CRF250L ABS','CRF250LABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Dual Sport','CRF250L Rally','CRF250LR'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Dual Sport','CRF250L Rally ABS','CRF250LRABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Dual Sport','CRF300L ','CRF300L '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Dual Sport','CRF300L Rally','CRF300LR'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Dual Sport','CRF450L ','CRF450L '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Dual Sport','CRF450RL ','CRF450RL '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Dual Sport','X-ADV ','X-ADV '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Dual Sport','XR650L ','XR650L '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','MiniMOTO','Monkey ','Monkey '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','MiniMOTO','Monkey ABS','MonkeyABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','MiniMOTO','MSX 125 Grom ABS','MSX125ABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','MiniMOTO','MSX 125 Grom','MSX125 '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','MiniMOTO','Super Cub C125','C125'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','MiniMOTO','Trail 125 ABS','TRL125ABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Neo-Sports Cafe','CB1000R ','CB1000R '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Neo-Sports Cafe','CB1000R Black Edition','CB1000RBE'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Neo-Sports Cafe','CB300R ABS','CB300RABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Neo-Sports Cafe','CB650R ABS','CB650RABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Scooter','ADV150 ','ADV150 '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Scooter','PCX125 ','PCX125 '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Scooter','PCX150 ','PCX150 '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Scooter','PCX150 ABS','PCX150ABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Scooter','SH Mode 125','SHM125'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Scooter','SH350i ','SH350i '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Sport','CB125F ','CB125F '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Sport','CB500F ABS','CB500FABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Supersport','CBR1000RR ','CBR1000RR '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Supersport','CBR1000RR ABS','CBR1000RRABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Supersport','CBR1000RR-R Fireblade SP','CBR1000RRRFSP'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Supersport','CBR125R ','CBR125R '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Supersport','CBR300R ','CBR300R '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Supersport','CBR300R ABS','CBR300RABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Supersport','CBR500R ','CBR500R '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Supersport','CBR500R ABS','CBR500RABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Supersport','CBR600RR ','CBR600RR '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Supersport','CBR600RR ABS','CBR600RRABS'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Supersport','CBR650R ','CBR650R '));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Touring','Gold Wing ','GL1800HPN7'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Touring','Gold Wing Tour DCT Airbag','GL1800HPN7TAD'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Touring','Gold Wing DCT','GL1800HPN7A'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Touring','Gold Wing Tour','GL1800HPN7T'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','Street','Touring','Gold Wing Tour DCT','GL1800HPN7TD'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','SXS','Rec/Utility','Pioneer 1000','PNR1000'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','SXS','Rec/Utility','Pioneer 1000 Special Edition','PNR1000SE'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','SXS','Rec/Utility','Pioneer 1000-5','PNR10005'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','SXS','Rec/Utility','Pioneer 1000-5 Special Edition','PNR10005SE'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','SXS','Rec/Utility','Pioneer 500','PNR500'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','SXS','Rec/Utility','Pioneer 520','PNR520'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','SXS','Rec/Utility','Pioneer 700','PNR700'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','SXS','Rec/Utility','Pioneer 700-4','PNR7004'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','SXS','Sport','Talon 1000R','TLN1000R'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','SXS','Sport','Talon 1000R FOX LIVE VALVE','TLN1000RFLV'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','SXS','Sport','Talon 1000R Special Edition','TLN1000RSE'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','SXS','Sport','Talon 1000X','TLN1000X'));
        modelDataObj.powersportsRecords.add(new PowerSports('2021','SXS','Sport','Talon 1000X FOX LIVE VALVE','TLN1000XFLV'));


        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Super Quiet','EU1000i','XXXXXX001'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Super Quiet','EU2200i','XXXXXX002'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Super Quiet','EU2200i Camo','XXXXXX003'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Super Quiet','EU2200i Companion','XXXXXX004'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Super Quiet','EU3000iS','XXXXXX005'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Super Quiet','EU7000iS','XXXXXX006'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Super Quiet','EB2200i','XXXXXX007'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Industrial Generators','EB2800i','XXXXXX008'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Industrial Generators','EB3000c','XXXXXX009'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Industrial Generators','EB5000','XXXXXX010'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Industrial Generators','EB6500','XXXXXX011'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Industrial Generators','EB10000','XXXXXX012'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Industrial Generators','EU1000i','XXXXXX013'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Industrial Generators','EU2200i','XXXXXX014'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Industrial Generators','EU3000iS','XXXXXX015'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Industrial Generators','EG4000','XXXXXX016'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Industrial Generators','EB2200i','XXXXXX017'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Industrial Generators','EB2800i','XXXXXX018'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Industrial Generators','EB3000c','XXXXXX019'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Industrial Generators','EB5000','XXXXXX020'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Industrial Generators','EB6500','XXXXXX021'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Industrial Generators','EB10000','XXXXXX022'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Economy','EG2800i','XXXXXX023'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Economy','EG4000','XXXXXX024'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Deluxe','EU7000iS','XXXXXX025'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Deluxe','EM5000SX','XXXXXX026'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Generators','Deluxe','EM6500SX','XXXXXX027'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Lawn Mowers','HRX Premium Residential','HRX217VKA','XXXXXX028'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Lawn Mowers','HRX Premium Residential','HRX217VLA','XXXXXX029'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Lawn Mowers','HRX Premium Residential','HRX217VYA','XXXXXX030'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Lawn Mowers','HRX Premium Residential','HRX217HYA','XXXXXX031'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Lawn Mowers','HRX Premium Residential','HRX217HZA','XXXXXX032'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Lawn Mowers','HRN Residential','HRN216PKA','XXXXXX033'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Lawn Mowers','HRN Residential','HRN216VKA','XXXXXX034'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Lawn Mowers','HRN Residential','HRN216VYA','XXXXXX035'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Lawn Mowers','HRN Residential','HRN216VLA','XXXXXX036'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Lawn Mowers','HRS Side Discharge','HRS216PKA','XXXXXX037'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Lawn Mowers','HRS Side Discharge','HRS216VKA','XXXXXX038'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Lawn Mowers','HRC Commercial','HRC216PDA','XXXXXX039'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Lawn Mowers','HRC Commercial','HRC216HDA','XXXXXX040'));
        modelDataObj.powerEquipmentRecords.add(new PowerEquipments('Lawn Mowers','HRC Commercial','HRC216HXA','XXXXXX041'));


        modelDataObj.marineRecords.add(new Marine('Portable', 'BF2.3', 'XXXXXX089'));
        modelDataObj.marineRecords.add(new Marine('Portable', 'BF5', 'XXXXXX090'));
        modelDataObj.marineRecords.add(new Marine('Portable', 'BF8-9.9', 'XXXXXX091'));
        modelDataObj.marineRecords.add(new Marine('Portable', 'BF15-20', 'XXXXXX092'));
        modelDataObj.marineRecords.add(new Marine('Mid-Range', 'BF25-30', 'XXXXXX093'));
        modelDataObj.marineRecords.add(new Marine('Mid-Range', 'BF40-50', 'XXXXXX094'));
        modelDataObj.marineRecords.add(new Marine('Mid-Range', 'BF60-BFP60', 'XXXXXX095'));
        modelDataObj.marineRecords.add(new Marine('Mid-Range', 'BF75-90-100', 'XXXXXX096'));
        modelDataObj.marineRecords.add(new Marine('High Power', 'BF115', 'XXXXXX097'));
        modelDataObj.marineRecords.add(new Marine('High Power', 'BF135-150', 'XXXXXX098'));
        modelDataObj.marineRecords.add(new Marine('High Power', 'BF200-225-250', 'XXXXXX099'));
        modelDataObj.marineRecords.add(new Marine('Jet Drive', '40 Jet', 'XXXXXX100'));
        modelDataObj.marineRecords.add(new Marine('Jet Drive', '65 Jet', 'XXXXXX101'));
        modelDataObj.marineRecords.add(new Marine('Jet Drive', '105 Jet', 'XXXXXX102'));

        return modelDataObj;
    }
}