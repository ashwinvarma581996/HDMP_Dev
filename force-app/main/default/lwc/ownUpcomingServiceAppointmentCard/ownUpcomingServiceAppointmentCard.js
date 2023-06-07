import { api, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import getServiceAppointments from '@salesforce/apex/OwnAPIController.getServiceAppointments';

export default class OwnUpcomingServiceAppointmentCard extends OwnBaseElement {

    @api title = 'UPCOMING SERVICE APPOINTMENT';
    @api titlecolor = 'Black';
    @api brandForContent = 'honda';
    @track showFooter = false;
    @track iconImage = this.myGarageResource() + '/ahmicons/wrench.svg';
    @api brand;
    @track allServiceAppointments;
    @track isDataLoading = true;
    @track errorMessage = '';
    @track error = false;
    @track showWarningIcon = true;

    connectedCallback(){
        let divisionId;
        if(this.brand == 'Honda'){
            divisionId = 'A';
        }else if(this.brand == 'Acura'){
            divisionId = 'B';
        }    

        if(divisionId){
            getServiceAppointments({divisionId : divisionId}).then(response => {
                //console.log('Service Appointments Response : ',response);
                
                if(!response.isError){
                    let allAppointments = JSON.parse(JSON.stringify(response.appointments));
                    if(allAppointments.length == 0){
                        this.error = true;
                        this.errorMessage = 'No Upcoming Service Appointments Found'; 
                        this.showWarningIcon = false;
                    }else{
                        this.allServiceAppointments = [];
                        allAppointments.forEach((appointment, index) => {
                            appointment.sno = index + 1;
                            this.allServiceAppointments.push(appointment);
                        });
                    }

                    
                    // response.appointments.forEach(element => {
                    //     this.allServiceAppointments.push({
                    //         appointmentForDisplay: element.appointmentForDisplay, 
                    //         appointmentIdent: element.appointmentIdent,
                    //         appointmentVendorID: element.appointmentVendorID, 
                    //         apptPrimaryServiceType: element.apptPrimaryServiceType,
                    //         apptScheduledDate: element.apptScheduledDate,
                    //         apptStatusCd: element.apptStatusCd,
                    //         apptStatusNameDisplay: element.apptStatusNameDisplay,
                    //         dealerName: element.dealerName,
                    //         dealerNo: element.dealerNo,
                    //         modelName: element.modelName,
                    //         modelYear: element.modelYear,
                    //         oldAppointmentIdent: element.oldAppointmentIdent,
                    //         ossProviderCd: element.ossProviderCd
                    //     });
                    // });

                    //console.log('This is final list of appointments : ',this.allServiceAppointments);
                    this.isDataLoading = false;
                }else{
                    this.error = true;
                    this.errorMessage = 'Unable to load service appointments';
                    this.isDataLoading = false;
                }

            }).catch(err => {
                this.error = true;
                this.errorMessage = 'Unable to load service appointments';
                this.isDataLoading = false;
                //console.log('Error Occured :: ',err);
            });
        }else{
            this.error = true;
            this.errorMessage = 'Unable to load service appointments';
            this.isDataLoading = false;
            //console.log('Division Not Loaded',divisionId);
        }
    }
}