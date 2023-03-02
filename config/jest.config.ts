import {Config} from 'jest';
import {Plugin} from '../src/plugin'
const p = new Plugin([]);
const c: Config = {
    rootDir: "../src",
    collectCoverage: true,
    coverageDirectory: "./coverage",
    coverageProvider: "v8",
    coverageReporters: ["html", "lcov", "json", "json-summary"]
}

export default c;