```mermaid
  flowchart TD
    subgraph Onboarding
      s1(IntroScreen)-- Continue -->s2(PhoneNumberScreen)
      s2-- Submit phone number -->s3(SmsCodeScreen);
      s3--Back-->s2
      s3--Submit SMS code-->s4(PermissionsScreen)
      s4--Approve / deny permissions-->s5(ReadyWeb3Screen)

      s5--No wallet installed-->s7(TermsScreen)
      s7--Sign terms-->s12(PfpAvatarScreen)
      s12--Select Profile Picture-->s10

      s5--Wallet installed-->s6(ConnectWalletScreen)
      s9--Back-->s5
      s6--Connect wallet-->s8(SignWalletScreen)
      s8--Sign terms-->s9(PfpNftScreen)
      s9--Select Profile Picture-->s10(DisplayNameScreen)
      s10--Claim Display Name-->s11(SettingThingsUpScreen)

      subgraph Web3
        s6
        s8
        s9
      end

      subgraph Web2
        s2
        s3
        s4
        s7
        s12
      end
    end

    subgraph Home
      s13(MapScreen)--My Profile-->s14(ProfileScreen)
      s14--Map-->s13
      s14--Add Network-->s15(AddNetworkBottomDialog)
      s15--Submit / Close-->s14
    end
    Onboarding--Onboarding complete-->Home
```
