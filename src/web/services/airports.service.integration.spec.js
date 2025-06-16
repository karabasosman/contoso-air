const AirportsService = require("./airports.service");
const airportsJSON = require("../data/airports");

describe("[Integration] Airports Service with real data", () => {
  it("finds İzmir airport correctly in real data", () => {
    const airports = new AirportsService(airportsJSON);
    
    const izmir = airports.getByCode("ADB");
    expect(izmir.city).toBe("İzmir");
    expect(izmir.name).toBe("Adnan Menderes Airport");
    expect(izmir.country).toBe("Turkey");
    expect(izmir.code).toBe("ADB");
  });

  it("includes İzmir in the list of all airports", () => {
    const airports = new AirportsService(airportsJSON);
    
    const all = airports.getAll();
    const izmirAirport = all.find(airport => airport.code === "ADB");
    
    expect(izmirAirport).toBeDefined();
    expect(izmirAirport.city).toBe("İzmir");
    expect(izmirAirport.name).toBe("Adnan Menderes Airport");
  });
});