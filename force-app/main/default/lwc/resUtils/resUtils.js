import jsonCrush from "c/jsonCrush";

/**
 * Encode base64 for url
 * @param {String} string - any kind of text
 * @return {String} string - base64 formatted string friendly for URL
 */
export const b64EncodeUrlFriendly = (string) => {
    const escapedEncodeChar = (char) => {
        switch (char) {
            case "+":
                return "-";
            case "/":
                return "_";
            case "=":
                return ".";
            default:
                return char;
        }
    };
    return btoa(string).replace(/[+/=]/g, escapedEncodeChar);
};

/**
 * Decode base64 from an url
 * @param {String} string - base64 formatted string friendly for URL
 * @return {String} string - decoded base64
 */
export const b64DecodeUrlFriendly = (string) => {
    const escapedDecodeChar = (char) => {
        switch (char) {
            case "-":
                return "+";
            case "_":
                return "/";
            case ".":
                return "=";
            default:
                return char;
        }
    };
    return atob(string.replace(/[-_.]/g, escapedDecodeChar));
};

export const compressJSONString = (string) => {
    return b64EncodeUrlFriendly(jsonCrush.crush(string));
}

export const deCompressJSONString = (string) => {
    return jsonCrush.uncrush(b64DecodeUrlFriendly(string));
}