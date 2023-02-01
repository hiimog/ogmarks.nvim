INSERT INTO tag ("name") VALUES ('foo'), ('bar');

INSERT INTO ogmark (
    "absolutePath",
    "created",
    "description",
    "name",
    "row",
    "rowText",
    "updated"
) VALUES (
    '/src/ogmarks.nvim/tests/text/lorem.txt',
    '20230131211350',
    'a description',
    'the name',
    3,
    'mea ad idque decore docendi.',
    '20230131211350'
);
INSERT INTO ogmarkTag VALUES(1, 1);
INSERT INTO ogmarkTag VALUES(1, 2);