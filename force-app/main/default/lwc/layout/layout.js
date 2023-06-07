import { LightningElement, api } from 'lwc';

/**
 * An organized display of product cards.
 *
 * @fires SearchLayout#calltoaction
 * @fires SearchLayout#showdetail
 */
export default class SearchLayoutCustom extends LightningElement {
    

    /**
     * Gets or sets the display data for layout.
     *
     * @type {Product[]}
     */
    @api
    displayData;

    /**
     * Gets or sets the layout configurations.
     *
     * @type {LayoutConfig}
     */
    @api
    config;

    /**
     * Gets the container class which decide the innter element styles.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get layoutContainerClass() {
       // console.log('here');
        return this.config.resultsLayout === 'grid'
            ? 'layout-grid'
            : 'layout-list';
    }
}