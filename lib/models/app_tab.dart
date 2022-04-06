enum AppTabEnum { feed, map, profile }

class AppTab {
  final AppTabEnum tab;
  final String title;
  AppTab(this.tab, this.title);

  factory AppTab.create(AppTabEnum tab) {
    switch (tab) {
      case AppTabEnum.feed:
        return AppTab(tab, "Nearby Networks");
      case AppTabEnum.map:
        return AppTab(tab, "WiFi Map");
      case AppTabEnum.profile:
        return AppTab(tab, "My Profile");
    }
  }
}
