//============================================================================
// Title:    Honda Owners Experience - Navigation Utility
// Summary:  Common logic to support Navigation in Honda's Salesforce Community for Owners Experience
// Details:  Common logic from Appirio.  Refer to ownBaseElement.lwc for details
//
// Sample Usage:
// 1) add this line into the js of your lwc 
//  import { generateNavigationTarget } from "c/ownNavigationUtility";
// 2) navigate(targetString, context = {});
//--------------------------------------------------------------------------------------
//
// History:
// April 9, 2021 Jim Kohs (Wipro) DOE-zzz Initial coding
//===========================================================================
const merge = (mergeString, context) => {
    const stringToMerge = mergeString.trim();
    if (stringToMerge.startsWith('{') && stringToMerge.endsWith('}')) {
        const key = stringToMerge.slice(1, -1);
        if (context[key]) {
            return context[key];
        }
    }
    return mergeString;
};

const generateNavigationTarget = (targetPage, context = {}) => {
    if (targetPage) {
        try {
            // split target string
            // part[0] = type
            const [targetType, ...targetParts] = targetPage.split(':');
            const target = { type: targetType, attributes: {} };
            // reusable params : {id}
            //console.log('Target Type : ',targetType);
            //switch on type
            switch (targetType) {
                case 'standard__app':
                    target.attributes.appTarget = merge(
                        targetParts[0],
                        context
                    );
                    if (targetParts.length > 1) {
                        targetParts.shift();
                        target.attributes.pageRef = generateNavigationTarget(
                            targetParts.join(':')
                        );
                    }
                    break;
                case 'standard__component':
                    target.attributes.componentName = merge(
                        targetParts[0],
                        context
                    );
                    if (targetParts.length > 1) {
                        targetParts.shift();
                        target.state = {};
                        targetParts
                            .join(':')
                            .split(',')
                            .forEach((pair) => {
                                const [key, value] = pair.split(':');
                                target.state[key] = merge(value, context);
                            });
                    }
                    break;
                case 'comm__loginPage':
                    target.attributes.actionName = merge(
                        targetParts[0],
                        context
                    );
                    break;
                case 'standard__knowledgeArticlePage':
                    target.attributes.articleType = merge(
                        targetParts[0],
                        context
                    );
                    target.attributes.urlName = merge(targetParts[1], context);
                    break;
                case 'standard__namedPage':
                    target.attributes.pageName = merge(targetParts[0], context);
                    break;
                case 'comm__namedPage':
                    target.attributes.name = merge(targetParts[0], context);
                    break;
                case 'standard__navItemPage':
                    target.attributes.apiName = merge(targetParts[0], context);
                    break;
                case 'standard__objectPage':
                    target.attributes.objectApiName = merge(
                        targetParts[0],
                        context
                    );
                    target.attributes.actionName = merge(
                        targetParts[1],
                        context
                    );
                    target.state = {};
                    if (
                        targetParts[2] &&
                        target.attributes.actionName === 'list' &&
                        targetParts[2] !== 'nooverride'
                    ) {
                        //list-only :{filterName}
                        target.attributes.filterName = merge(
                            targetParts[2],
                            context
                        );
                    } else if (
                        targetParts[2] &&
                        target.attributes.actionName === 'new' &&
                        targetParts[2] !== 'nooverride'
                    ) {
                        //new-only :{field:value},
                        target.state.defaultFieldValues = merge(
                            targetParts[2],
                            context
                        );
                    }

                    if (targetParts[targetParts.length - 1] === 'nooverride') {
                        //:nooverride (at end)
                        target.state.nooverride = 1;
                    }
                    break;
                case 'standard__recordPage':
                    target.attributes.objectApiName = merge(
                        targetParts[0],
                        context
                    );
                    target.attributes.actionName = merge(
                        targetParts[1],
                        context
                    );
                    target.attributes.recordId = merge(targetParts[2], context);
                    break;
                case 'standard__recordRelationshipPage':
                    target.attributes.objectApiName = merge(
                        targetParts[0],
                        context
                    );
                    target.attributes.actionName = merge(
                        targetParts[1],
                        context
                    );
                    target.attributes.recordId = merge(targetParts[2], context);
                    target.attributes.relationshipApiName = merge(
                        targetParts[3],
                        context
                    );
                    break;
                case 'standard__webPage':
                    target.attributes.url = merge(targetParts[0], context);
                    break;
                case 'modal':
                    target.isModal = true;
                    target.type = targetParts[0]; //flow or component
                    targetParts.shift();
                    //component:c:componentName:attr1:attr1Val,attr2:attr2val,
                    if (target.type === 'component') {
                        target.componentName = targetParts
                            .slice(0, 2)
                            .join(':');
                        targetParts.shift();
                        targetParts.shift();
                    }
                    //flow:example_flow_name:attr1:attr1val,attr2:attr2val,...
                    else if (target.type === 'flow') {
                        target.flowName = targetParts[0];
                        targetParts.shift();
                    }
                    target.attributes = {};
                    targetParts
                        .join(':')
                        .split(',')
                        .forEach((pair) => {
                            const [key, value] = pair.split(':');
                            target.attributes[key] = merge(value, context);
                        });
                    break;
                default:
                    if (
                        targetType.startsWith('/') ||
                        targetType.startsWith('http')
                    ) {
                        target.type = 'standard__webPage';
                        target.attributes.url = targetPage;
                    } else if (targetParts && targetParts.length > 0) {
                        target.type = 'standard__objectPage';
                        target.attributes.objectApiName = targetParts[0];
                        target.actionName = targetPageParts[1] || 'home';
                    } else if (
                        targetPage.startsWith('{') &&
                        targetPage.endsWith('}')
                    ) {
                        const targetObject = JSON.parse(targetPage);
                        target.type = targetObject.type;
                        delete targetObject.type;
                        target.attributes = targetObject;
                    } else {
                        target.type = 'comm__namedPage';
                        target.attributes.name = targetType;
                    }
                    break;
            }

            return target;
        } catch (err) {
            throw new Error('Invalid Target Page Provided.');
        }
    } else {
        throw new Error('Missing Target Page');
    }
};

export { generateNavigationTarget };