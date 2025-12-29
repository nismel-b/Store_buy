//choice a category of user
enum UserType {
  vendor,
  customer,
}

class User{
 final String userId;
 final String name;
 final String username;
 final String email;
 final String phonenumber;
 final String password;
 final String location;
 final UserType userType;

  //parameter constructor
  User(
      this.userId,
      this.name,
      this.username,
      this.email,
      this.phonenumber,
      this.password,
      this.location,
      this.userType,
      );

  //select a category of user: customer or vendor
 bool get isVendor => userType == UserType.vendor;
 bool get isCustomer => userType == UserType.customer;

}