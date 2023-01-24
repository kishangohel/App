#!/usr/bin/env python3
import os

from firebase_admin import credentials, firestore
import firebase_admin

ACHIEVEMENTS = [
    {
        "Identifier": "AccessPointCreator",
        "StatisticsKey": "AccessPointsCreated",
        "Name": "Access Point Creator",
        "Description": "Create access points",
        "ListPriority": 100,
        "Tiers": [
            {
                "Identifier": "BronzeTier",
                "GoalTotal": 3,
                "VeriPointsAward": 20,
            },
            {
                "Identifier": "SilverTier",
                "GoalTotal": 10,
                "VeriPointsAward": 40,
            },
            {
                "Identifier": "GoldTier",
                "GoalTotal": 25,
                "VeriPointsAward": 60,
            },
        ],
    },
    {
        "Identifier": "AccessPointValidator",
        "StatisticsKey": "AccessPointsValidated",
        "Name": "Access Point Validator",
        "Description": "Validate access points",
        "ListPriority": 200,
        "Tiers": [
            {
                "Identifier": "BronzeTier",
                "GoalTotal": 3,
                "VeriPointsAward": 20,
            },
            {
                "Identifier": "SilverTier",
                "GoalTotal": 10,
                "VeriPointsAward": 40,
            },
            {
                "Identifier": "GoldTier",
                "GoalTotal": 25,
                "VeriPointsAward": 60,
            },
        ],
    },
    # {
    #     "Identifier": "TwitterVeriFied",
    #     "StatisticsKey": "TwitterVeriFied",
    #     "Name": "Twitter VeriFied",
    #     "ListPriority": 300,
    #     "Tiers": [
    #         {
    #             "Identifier": "SilverTier",
    #             "Description": "Connect your Twitter account",
    #             "GoalTotal": 1,
    #             "VeriPointsAward": 40,
    #         },
    #         {
    #             "Identifier": "GoldTier",
    #             "Description": "Post VeriFied tweet",
    #             "GoalTotal": 2,
    #             "VeriPointsAward": 60,
    #         },
    #     ],
    # },
]


def create_achievements(db):
    # Create Achievements
    for i in range(len(ACHIEVEMENTS)):
        db.collection("Achievement").add(ACHIEVEMENTS[i])


if __name__ == "__main__":
    os.environ["FIREBASE_AUTH_EMULATOR_HOST"] = os.getenv(
        "FIREBASE_AUTH_EMULATOR_HOST",
        "localhost:9099",
    )
    os.environ["FIRESTORE_EMULATOR_HOST"] = os.getenv(
        "FIRESTORE_EMULATOR_HOST",
        "localhost:8080",
    )
    cred = credentials.Certificate("mock_service_account.json")
    firebase_admin.initialize_app(credential=cred)
    db = firestore.client()

    create_achievements(db)
