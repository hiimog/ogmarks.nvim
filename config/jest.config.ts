import {Config} from 'jest';
const c: Config = {
    collectCoverage: true,
    coverageDirectory: "./coverage",
    coverageProvider: "v8",
    coverageReporters: ["html", "lcov", "json", "json-summary"]
}

export default c;