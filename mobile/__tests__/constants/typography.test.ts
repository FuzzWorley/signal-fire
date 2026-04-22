import { FontFamily, FontSize } from "../../constants/typography";

describe("FontFamily", () => {
  it("exports serifDisplay", () => {
    expect(FontFamily.serifDisplay).toBe("InstrumentSerif_400Regular");
  });

  it("exports sans (regular)", () => {
    expect(FontFamily.sans).toBe("InstrumentSans_400Regular");
  });

  it("exports sansMedium", () => {
    expect(FontFamily.sansMedium).toBe("InstrumentSans_500Medium");
  });

  it("exports sansSemiBold", () => {
    expect(FontFamily.sansSemiBold).toBe("InstrumentSans_600SemiBold");
  });

  it("exports mono", () => {
    expect(FontFamily.mono).toBe("JetBrainsMono_400Regular");
  });

  it("exports all 5 font families", () => {
    expect(Object.keys(FontFamily)).toHaveLength(5);
  });
});

describe("FontSize", () => {
  it("exports xs as the smallest size", () => {
    expect(FontSize.xs).toBe(11);
  });

  it("exports sm", () => {
    expect(FontSize.sm).toBe(13);
  });

  it("exports base", () => {
    expect(FontSize.base).toBe(15);
  });

  it("exports lg", () => {
    expect(FontSize.lg).toBe(17);
  });

  it("exports xl", () => {
    expect(FontSize.xl).toBe(20);
  });

  it("exports xxl", () => {
    expect(FontSize.xxl).toBe(26);
  });

  it("exports display as the largest size", () => {
    expect(FontSize.display).toBe(34);
  });

  it("sizes are in ascending order", () => {
    const sizes = [
      FontSize.xs,
      FontSize.sm,
      FontSize.base,
      FontSize.lg,
      FontSize.xl,
      FontSize.xxl,
      FontSize.display,
    ];
    for (let i = 1; i < sizes.length; i++) {
      expect(sizes[i]).toBeGreaterThan(sizes[i - 1]);
    }
  });
});
