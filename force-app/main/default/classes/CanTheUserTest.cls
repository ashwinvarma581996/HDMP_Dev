@isTest
private inherited sharing class CanTheUserTest {
    // These tests rely on the assumption that standard FLS/CRUD have not been modified
    // by the user, and use the Account Object for verification of the Can Logic.

    @isTest
    static void canCrudAccountCreatePositive() {
        System.assert(
            CanTheUser.crud(new Account(), CanTheUser.CrudType.CREATE),
            'Unless scratch org defaults have been changed by the user, this test should pass - asserting that users can create accounts'
        );
    }

    @isTest
    static void canCrudCreateAccountPositive() {
        System.assert(
            CanTheUser.create(new Account()),
            'Unless scratch org defaults have been changed by the user, this test should pass - asserting that users can create accounts'
        );
    }

    @isTest
    static void canCrudAccountReadPositive() {
        System.assert(
            CanTheUser.crud(new Account(), CanTheUser.CrudType.READ),
            'Expected to be able to read accounts'
        );
    }

    @isTest
    static void canCrudReadAccountPositive() {
        System.assert(
            CanTheUser.read(new Account()),
            'Expected to be able to read accounts'
        );
    }

    @isTest
    static void canCrudAccountUpdatePositive() {
        System.assert(
            CanTheUser.crud(new Account(), CanTheUser.CrudType.EDIT),
            'Expected to be able to update accounts'
        );
    }

    @isTest
    static void canCrudEditAccountPositive() {
        System.assert(
            CanTheUser.edit(new Account()),
            'Expected to be able to update accounts'
        );
    }

    @isTest
    static void canCrudAccountDeletePositive() {
        System.assert(
            CanTheUser.crud(new Account(), CanTheUser.CrudType.DEL),
            'Expected to be able to delete accounts'
        );
    }

    @isTest
    static void canCrudDestroyAccountPositive() {
        System.assert(
            CanTheUser.destroy(new Account()),
            'Expected to be able to delete accounts'
        );
    }
}