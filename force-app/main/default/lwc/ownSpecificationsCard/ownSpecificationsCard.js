//============================================================================
// Title:    Honda Owners Experience - Specifications Card
//
// Summary:  This Card links to the Specifications
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

export default class OwnSpecificationsCard extends OwnBaseElement {

	@api title = 'SPECIFICATIONS';
	@api icon = 'checklist.svg';
	@api titlecolor = 'Honda Red';
	@api brand = 'default';
	@track showFooter = false;
	@track cardDivClass = '';

	connectedCallback() {
		this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
		if (document.title == 'Garage' || document.title == 'Garage' || document.title == 'Garage') {
			this.cardDivClass = 'overview-tab-class';
			//console.log('Document title ::: ', document.title);
		}
	}

	async handleHeader() {
		//this.navigate('/help-center', {});
		let eventMetadata = {
			action_type: 'link',
			action_category: 'body',
			action_label: this.title
		};
		let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
		this.publishToChannel(message);
		if (document.location.pathname.includes('-resources-downloads')) {
			sessionStorage.setItem('frompage', 'Resources & Downloads');
		}
		if (document.location.pathname.includes('-service-maintenance')) {
			sessionStorage.setItem('frompage', 'Service & Maintainance');
		}
		if (document.location.pathname.includes('garage-')) {
			sessionStorage.setItem('frompage', 'Overview');
		}
		await this.sleep(2000);
		this.navigate('/specifications', {}); //Brett Spokes DOE-2495
		/*	if (document.location.pathname.includes('-resources-downloads')) {
				sessionStorage.setItem('frompage', 'Resourses & Downloads');
			}
			if (document.location.pathname.includes('-service-maintenance')) {
				sessionStorage.setItem('frompage', 'Service & Maintainance');
			}
			if (document.location.pathname.includes('garage-')) {
				sessionStorage.setItem('frompage', 'Overview');
			}
			this.navigate(this.headerlink, {});*/
	}

	handleAction() {
		console.log('action');
	}

	handleFooter() {
		console.log('footer');
	}

	sleep(ms) {
		return new Promise(resolve => setTimeout(resolve, ms));
	}
	get bodyClass() {
		return this.showfooter ? 'slds-card__body_inner card-body-footer' : 'slds-card__body_inner card-body';
	}

	get titleClass() {
		return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : 'slds-text-heading_small title';
	}

	get iconClass() {
		return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
	}

	get body() {
		let bodyLine = '';

		bodyLine = (this.brand === 'Acura') ? 'Learn more about the technical specifications of your Acura.' : bodyLine;
		bodyLine = (this.brand === 'Honda') ? 'Learn more about the technical specifications of your Honda.' : bodyLine;
		bodyLine = (this.brand === 'Powersports') ? 'Learn more about the technical specifications of your Honda Powersports vehicle.' : bodyLine;
		bodyLine = (this.brand === 'Power Equipment') ? 'Learn more about the technical specifications of your product.' : bodyLine;
		bodyLine = (this.brand === 'Marine') ? 'Learn more about the technical specifications of your product.' : bodyLine;

		return bodyLine;
	}

}