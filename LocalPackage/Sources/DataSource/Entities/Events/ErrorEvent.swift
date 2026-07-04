/*
 ErrorEvent.swift
 DataSource

 Created by Takuto Nakamura on 2026/07/04.
 Copyright 2026 Kyome22 (Takuto Nakamura)

 This software is released under the MIT License, see LICENSE.
 */

import Logging

public enum ErrorEvent {
    // MIGRATION: One case per recoverable failure worth logging, named xxxFailed(any Error):
    // case importingFrameImagesFailed(any Error)
    // While this enum has no cases the compiler warns "will never be executed" in LogService — it
    // disappears once the first case is added.

    public var message: Logger.Message {
        switch self {
        // MIGRATION: Sentence-style message per case, e.g. "Failed importing frame images."
        }
    }

    public var metadata: Logger.Metadata? {
        switch self {
        // MIGRATION: Bind associated errors and emit ["cause": "\(error.localizedDescription)"].
        }
    }
}
