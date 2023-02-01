CREATE TABLE ogmark (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    absolutePath TEXT,
    created TEXT NOT NULL,
    description TEXT,
    name TEXT,
    row INTEGER NOT NULL,
    rowText TEXT NOT NULL,
    updated TEXT NOT NULL
);

CREATE TABLE tag (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE ogmarkTag (
    ogmarkId INTEGER,
    tagId INTEGER,
    PRIMARY KEY (ogmarkId, tagId),
    FOREIGN KEY(ogmarkId) REFERENCES ogmark(id) ON DELETE CASCADE,
    FOREIGN KEY(tagId) REFERENCES tag(id) ON DELETE CASCADE
);