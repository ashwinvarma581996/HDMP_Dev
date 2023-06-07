import LightningDatatable from 'lightning/datatable';
import imageFile from './imageFile.html';
export default class ImageDatatable extends LightningDatatable {
    static customTypes = {
        image: {
            template: imageFile
        }
    };
}