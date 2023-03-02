import exp from "constants";

export interface OgMark {
    id: number;
    row: number;
    rowText: string;
    description: string;
    tags: string[];
}

export function NewOgMark(id: number): OgMark {
    return {
        id,
        description: "",
        row: 1,
        rowText: "",
        tags: []
    }
}
