import { Colors } from "../../constants/colors";

describe("Colors", () => {
  it("exports ink color", () => {
    expect(Colors.ink).toBe("#1a1a12");
  });

  it("exports paper color", () => {
    expect(Colors.paper).toBe("#f2f0d9");
  });

  it("exports ember color", () => {
    expect(Colors.ember).toBe("#e24820");
  });

  it("exports emberLight color", () => {
    expect(Colors.emberLight).toBe("#fdf0ec");
  });

  it("exports stone color", () => {
    expect(Colors.stone).toBe("#867a60");
  });

  it("exports white color", () => {
    expect(Colors.white).toBe("#ffffff");
  });

  it("exports border color", () => {
    expect(Colors.border).toBe("#e0ddc8");
  });

  it("exports muted color", () => {
    expect(Colors.muted).toBe("#b0a88a");
  });

  it("exports glen color", () => {
    expect(Colors.glen).toBe("#d4a82d");
  });

  it("exports all 9 colors", () => {
    expect(Object.keys(Colors)).toHaveLength(9);
  });
});
