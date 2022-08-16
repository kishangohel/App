```mermaid
sequenceDiagram
  actor U as User
  participant A as Application
  participant L as Location API
  participant R as Remote Database

  U->>A: User opens VeriMap
  A->>L: Request user location
  L->>A: Return user location
  A->>R: Update user location
  par Show current user
    A->>U: Show user avatar on VeriMap
  and Show nearby WiFi access points (WAP)
    A->>R: Request nearby WAPs
    R->>A: Return nearby WAPs
    A->>U: Show nearby WAPs on VeriMap
  and Show nearby users
    A->>R: Request nearby users
    R->>A: Return nearby users
    A->>U: Show nearby users on VeriMap
  and Show users in digital community
    A->>R: Request users in digital community
    R->>A: Return users in digital community
    A->>U: Show users in digital community
  end
```
