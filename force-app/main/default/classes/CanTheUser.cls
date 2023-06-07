//****************************************************************************** 
// File Name:       OwnContext.cls
// Summary:         A reusable, intuitive library for determining wether or not the
//                  current use can create, read, edit, or delete objects as well as
//                  determining if the user has access or update permissions on specific fields.
//                  This class name was chosen to facilitate easy-to-understand and read code.
//
// Use:             Whenever you need to check FLS or CRUD access your code reads like this
//                      if(CanTheUser.read(new account())){}` making the calling and use of this code easy and intuitive.
 
// 
// Test Classes:    CanTheUserTest.cls
//===============================================================================
// Modification Log: 
// Apr 24, 2021 Arunprasad N (Appirio) initial coding
//*******************************************************************************
 
public inherited sharing class CanTheUser {
    /**
     * @description Internal custom exception class
     */
    public class CanTheUserException extends Exception {
    }

    public enum CrudType {
        CREATE,
        READ,
        EDIT,
        DEL
    }

    public enum FLSType {
        ACCESSIBLE,
        UPDATABLE
    }

    /**
     * This class' name was chosen to facilitate easy-to-understand and read
     * code. Whenever you need to check FLS or CRUD access your code reads like
     * this
     * `if(CanTheUser.read(new account())){}` making the calling and use of this
     * code easy and intuitive.
     */

    /**
     * @description
     * @param obj the object type to check
     * @param permission create, read, update or delete
     * @return Boolean
     * @example
     * System.debug(CanTheUser.crud(new Account(), CanTheUser.CrudType.READ));
     **/
    public static Boolean crud(SObject obj, CrudType permission) {
        switch on permission {
            when CREATE {
                return obj.getSObjectType().getDescribe().isCreateable();
            }
            when READ {
                return obj.getSObjectType().getDescribe().isAccessible();
            }
            when EDIT {
                return obj.getSObjectType().getDescribe().isUpdateable();
            }
            when DEL {
                return obj.getSObjectType().getDescribe().isDeletable();
            }
        }
        return false;
    }

    /**
     * @description convenience api for determining if the running user can
     * create the specified object
     * @param obj Object type to check create permissions on
     * @return Boolean
     * @example
     * System.debug(CanTheUser.create(new Account()));
     **/
    public static Boolean create(SObject obj) {
        return CanTheUser.crud(obj, CrudType.CREATE);
    }

    /**
     * @description convenience api for determining if the running user can
     * read / access the specified object
     * @param obj object type to check read permissions on
     * @return Boolean
     * @example
     * System.debug(CanTheUser.read(new Account()));
     **/
    public static Boolean read(SObject obj) {
        return CanTheUser.crud(obj, CrudType.READ);
    }

    /**
     * @description convenience api for determining if the running user can
     * edit / update the specified object
     * @param obj object type to check edit permissions on
     * @return Boolean
     * @example
     * System.debug(CanTheUser.edit(new Account()));
     **/
    public static Boolean edit(SObject obj) {
        return CanTheUser.crud(obj, CrudType.EDIT);
    }

    /**
     * @description convenience api for determining if the running user can
     * delete/destroy the specified object
     * @param obj object type to check destroy permissions on
     * @return Boolean
     * @example
     * System.debug(CanTheUser.destroy(new Account()));
     **/
    public static Boolean destroy(SObject obj) {
        return CanTheUser.crud(obj, CrudType.DEL);
    }
}