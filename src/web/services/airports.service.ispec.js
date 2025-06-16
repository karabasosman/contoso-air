const AirportsService = require("./index").AirportsService;

describe("[Int] That Airports Service", () => {
  it("has that all airports have a city", () => {
    const airports = AirportsService();
    const all = airports.getAll();
    expect(all.every((a) => a.city)).toBe(true);
  });

  it.each(["CDG", "JFK", "TOR", "BOS", "JFK", "FRA"])(
    "exists airport with code %s (used by flights)",
    (code) => {
      const airports = AirportsService();
      const airport = airports.getByCode(code);
      expect(airport.code).toBeTruthy();
      expect(airport.city).toBeTruthy();
    }
  );

  it.each(["SEA", "BCN", "HNL", "CDG", "NAR", "LHR", "SIN"])(
    "exists airport with code %s (used by deals)",
    (code) => {
      const airports = AirportsService();
      const airport = airports.getByCode(code);
      expect(airport.code).toBeTruthy();
      expect(airport.city).toBeTruthy();
    }
  );

  it("İzmir (ADB) airport exists with correct city name", () => {
    const airports = AirportsService();
    const izmir = airports.getByCode("ADB");
    expect(izmir.code).toBe("ADB");
    expect(izmir.city).toBe("İzmir");
    expect(izmir.country).toBe("Turkey");
    expect(izmir.name).toBe("Gaziemir Airport");
  });
});
