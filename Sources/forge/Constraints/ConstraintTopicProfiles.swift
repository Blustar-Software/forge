import Foundation

let topicConstraintProfiles: [ChallengeTopic: ConstraintProfile] = [
    .strings: ConstraintProfile(
        disallowedTokens: ["readLine", "CommandLine"],
        allowNetwork: true
    ),
    .conditionals: ConstraintProfile(
        disallowedTokens: ["for", "while", "repeat"],
        allowNetwork: true
    ),
    .loops: ConstraintProfile(
        disallowedTokens: ["readLine", "CommandLine"],
        allowNetwork: true
    ),
    .functions: ConstraintProfile(
        disallowedTokens: ["readLine", "CommandLine"],
        allowNetwork: true
    ),
    .collections: ConstraintProfile(
        disallowedTokens: ["readLine", "CommandLine"],
        allowNetwork: true,
        requireCollectionUsage: true
    ),
    .optionals: ConstraintProfile(
        disallowedTokens: ["readLine", "CommandLine"],
        allowNetwork: true,
        requireOptionalUsage: true
    ),
    .structs: ConstraintProfile(
        requiredTokens: ["struct"],
        allowNetwork: true
    ),
]
