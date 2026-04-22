import React from "react";
import { render, screen } from "@testing-library/react-native";
import { YouAreHereBanner } from "../../components/YouAreHereBanner";

describe("YouAreHereBanner", () => {
  it("renders the event title in the banner text", () => {
    render(<YouAreHereBanner eventTitle="Ecstatic Dance" />);
    expect(screen.getByText(/checked in to Ecstatic Dance/)).toBeTruthy();
  });

  it("renders the 'You're here' prefix", () => {
    render(<YouAreHereBanner eventTitle="AcroYoga Jam" />);
    expect(screen.getByText(/You're here/)).toBeTruthy();
  });
});
