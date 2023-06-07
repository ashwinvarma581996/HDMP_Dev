//============================================================================
// Title:    Honda Owners Experience - OwnCMSContent
//
//
// Details: Used to fetch CMS content records from Database based on the topics
//
//
// History:
// Oct 06, 2021 Yusuf Deshwali (Wipro) initial coding
//===========================================================================
import { LightningElement, wire } from 'lwc';
import getCMSRecords from '@salesforce/apex/OwnCMSContentFetcher.getContentList';

export default class OwnCMSContent extends LightningElement {}

export { getCMSContent };

async function getCMSContent(topics){
    let contents = [];
    await getCMSRecords(
        {
            topics : topics,
            page: 0,
            pageSize: null,
            language: 'en_US',
            filterby: ''
        }
    ).then(result => {
        contents = result;
    })
    .catch(error => {
       // console.log('error', error);
    });
    return contents;
}