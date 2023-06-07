import { api, LightningElement } from 'lwc';
// import CAROUSEL_IMAGES from '@salesforce/resourceUrl/Carousel_Images';
import HOME_CAROUSEL from '@salesforce/resourceUrl/Home_Carousel';
import HOME_SLIDER from '@salesforce/resourceUrl/Home_Slider';
import CAROUSEL_IMAGE from '@salesforce/resourceUrl/Carousel_image';
export default class CustomCarouselWrapper extends LightningElement {

    //varurl = window.location.href;

    get slides() {

        if (window.location.href.indexOf("/acura") > -1) {

            return [
                // {
                //     image: `${CAROUSEL_IMAGES}/Honda_images/honda_banner5.jpg`,
                //     heading: 'Radiant Red Metallic',
                //     description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                // },
                // {
                //     image: `${CAROUSEL_IMAGES}/Honda_images/honda_banner6.jpg`,
                //     heading: 'Aegean Blue Metallic',
                //     description: 'The CR-V boasts modern styling and sporty details that reflect its turbocharged personality'
                // },
                // {
                //     image: `${HOME_CAROUSEL}/Acura_Banner_JM_AR_01.jpg`,
                //     heading: 'Radiant Red Metallic',
                //     description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                // },
                // {
                //     image: `${HOME_CAROUSEL}/Acura_Banner_JM_AR_02.jpg`,
                //     heading: 'Radiant Red Metallic',
                //     description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                // },
                // {
                //     image: `${HOME_CAROUSEL}/Acura_Banner_JM_AR_03.jpg`,
                //     heading: 'Radiant Red Metallic',
                //     description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                // },
                {
                    image: `${HOME_SLIDER}/Acura_Banner_JM_AR_01_gm01.jpg`,
                    heading: 'Radiant Red Metallic',
                    description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                },
                {
                    image: `${HOME_SLIDER}/Acura_Banner_JM_AR_02_gm01.jpg`,
                    heading: 'Radiant Red Metallic',
                    description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                },
                {
                    image: `${HOME_SLIDER}/Acura_Banner_JM_AR_03_gm01.jpg`,
                    heading: 'Radiant Red Metallic',
                    description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                },
                {
                    image: `${CAROUSEL_IMAGE}/Honda_OnsiteBanner.jpg`,
                    heading: 'Radiant Red Metallic',
                    description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                },
                {
                    image: `${CAROUSEL_IMAGE}/Honda_OnsiteBanner3.jpg`,
                    heading: 'Radiant Red Metallic',
                    description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                },

            ]

        }
        if (window.location.href.indexOf("/honda") > -1) {

            return [
                // {
                //     image: `${CAROUSEL_IMAGES}/Honda_images/honda_banner1.jpg`,
                //     heading: 'Radiant Red Metallic',
                //     description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                // },
                // {
                //     image: `${CAROUSEL_IMAGES}/Honda_images/honda_banner2.jpg`,
                //     heading: 'Aegean Blue Metallic',
                //     description: 'The CR-V boasts modern styling and sporty details that reflect its turbocharged personality'
                // },
                // {
                //     image: `${CAROUSEL_IMAGES}/Honda_images/honda_banner3.jpg`,
                //     heading: 'Modern Steel Metallic',
                //     description: 'The CR-V Hybrid alerts you when its parking sensors detect that you’re approaching a vehicle'
                // },
                // {
                //     image: `${CAROUSEL_IMAGES}/Honda_images/honda_banner4.jpg`,
                //     heading: 'Modern Steel Metallic',
                //     description: 'The CR-V Hybrid alerts you when its parking sensors detect that you’re approaching a vehicle'
                // },
                // {
                //     image: `${HOME_CAROUSEL}/Honda_Banner_JM_AR_01.jpg`,
                //     heading: 'Radiant Red Metallic',
                //     description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                // },
                // {
                //     image: `${HOME_CAROUSEL}/Honda_Banner_JM_AR_02.jpg`,
                //     heading: 'Radiant Red Metallic',
                //     description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                // },
                // {
                //     image: `${HOME_CAROUSEL}/Honda_Banner_JM_AR_03.jpg`,
                //     heading: 'Radiant Red Metallic',
                //     description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                // },
                {
                    image: `${HOME_SLIDER}/Honda_Banner_JM_AR_01_gm01.jpg`,
                    heading: 'Radiant Red Metallic',
                    description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                },
                {
                    image: `${HOME_SLIDER}/Honda_Banner_JM_AR_02_gm01.jpg`,
                    heading: 'Radiant Red Metallic',
                    description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                },
                {
                    image: `${HOME_SLIDER}/Honda_Banner_JM_AR_03_gm01.jpg`,
                    heading: 'Radiant Red Metallic',
                    description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                },
                {
                    image: `${CAROUSEL_IMAGE}/Honda_OnsiteBanner2.jpg`,
                    heading: 'Radiant Red Metallic',
                    description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                },
                {
                    image: `${CAROUSEL_IMAGE}/Honda_OnsiteBanner4.jpg`,
                    heading: 'Radiant Red Metallic',
                    description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                }

            ]

        }

        if (window.location.href.indexOf("/s") > -1) {
            return [
                // {
                //         image: `${CAROUSEL_IMAGES}/Honda_images/honda_1.PNG`,
                //         heading: 'Radiant Red Metallic',
                //         description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                //     },
                //     {
                //         image: `${CAROUSEL_IMAGES2}/acura_1.png`,
                //         heading: 'Radiant Red Metallic',
                //         description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                //     },
                //     {
                //         image: `${CAROUSEL_IMAGES}/Honda_images/honda_2.PNG`,
                //         heading: 'Aegean Blue Metallic',
                //         description: 'The CR-V boasts modern styling and sporty details that reflect its turbocharged personality'
                //     },
                //     {
                //         image: `${CAROUSEL_IMAGES2}/acura_2.png`,
                //         heading: 'Aegean Blue Metallic',
                //         description: 'The CR-V boasts modern styling and sporty details that reflect its turbocharged personality'
                //     },
                //     {
                //     image: `${CAROUSEL_IMAGES}/Honda_images/honda_banner1.jpg`,
                //     heading: 'Radiant Red Metallic',
                //     description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                // },
                // {
                //     image: `${CAROUSEL_IMAGES}/Honda_images/honda_banner2.jpg`,
                //     heading: 'Radiant Red Metallic',
                //     description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                // },
                // {
                //     image: `${CAROUSEL_IMAGES}/Honda_images/honda_banner3.jpg`,
                //     heading: 'Radiant Red Metallic',
                //     description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                // },
                // {
                //     image: `${CAROUSEL_IMAGES}/Honda_images/honda_banner4.jpg`,
                //     heading: 'Radiant Red Metallic',
                //     description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                // },
                // {
                //     image: `${CAROUSEL_IMAGES}/Honda_images/honda_banner5.jpg`,
                //     heading: 'Radiant Red Metallic',
                //     description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                // },
                // {
                //     image: `${CAROUSEL_IMAGES}/Honda_images/honda_banner6.jpg`,
                //     heading: 'Radiant Red Metallic',
                //     description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                // },
                // {
                //     image: `${HOME_CAROUSEL}/Honda_Banner_JM_AR_01.jpg`,
                //     heading: 'Radiant Red Metallic',
                //     description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                // },
                // {
                //     image: `${HOME_CAROUSEL}/Acura_Banner_JM_AR_01.jpg`,
                //     heading: 'Radiant Red Metallic',
                //     description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                // },
                // {
                //     image: `${HOME_CAROUSEL}/Honda_Banner_JM_AR_02.jpg`,
                //     heading: 'Radiant Red Metallic',
                //     description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                // },
                // {
                //     image: `${HOME_CAROUSEL}/Acura_Banner_JM_AR_02.jpg`,
                //     heading: 'Radiant Red Metallic',
                //     description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                // },
                // {
                //     image: `${HOME_CAROUSEL}/Honda_Banner_JM_AR_03.jpg`,
                //     heading: 'Radiant Red Metallic',
                //     description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                // },
                // {
                //     image: `${HOME_CAROUSEL}/Acura_Banner_JM_AR_03.jpg`,
                //     heading: 'Radiant Red Metallic',
                //     description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                // },
                {
                    image: `${HOME_SLIDER}/Honda_Banner_JM_AR_01_gm01.jpg`,
                    heading: 'Radiant Red Metallic',
                    description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                },
                {
                    image: `${HOME_SLIDER}/Acura_Banner_JM_AR_01_gm01.jpg`,
                    heading: 'Radiant Red Metallic',
                    description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                },
                {
                    image: `${HOME_SLIDER}/Honda_Banner_JM_AR_02_gm01.jpg`,
                    heading: 'Radiant Red Metallic',
                    description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                },
                {
                    image: `${HOME_SLIDER}/Acura_Banner_JM_AR_02_gm01.jpg`,
                    heading: 'Radiant Red Metallic',
                    description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                },
                {
                    image: `${HOME_SLIDER}/Honda_Banner_JM_AR_03_gm01.jpg`,
                    heading: 'Radiant Red Metallic',
                    description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                },
                {
                    image: `${HOME_SLIDER}/Acura_Banner_JM_AR_03_gm01.jpg`,
                    heading: 'Radiant Red Metallic',
                    description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                },
                {
                    image: `${CAROUSEL_IMAGE}/Honda_OnsiteBanner2.jpg`,
                    heading: 'Radiant Red Metallic',
                    description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                },
                {
                    image: `${CAROUSEL_IMAGE}/Honda_OnsiteBanner.jpg`,
                    heading: 'Radiant Red Metallic',
                    description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                },
                {
                    image: `${CAROUSEL_IMAGE}/Honda_OnsiteBanner4.jpg`,
                    heading: 'Radiant Red Metallic',
                    description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                },
                {
                    image: `${CAROUSEL_IMAGE}/Honda_OnsiteBanner3.jpg`,
                    heading: 'Radiant Red Metallic',
                    description: 'Turn heads as easily as you turn corners in the 2021 CR-V'
                }
            ]
        }
        return this.slides;
    }

}