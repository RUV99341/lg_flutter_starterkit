/// KmlBuilder
/// ----------
/// Pure KML factory. Generates valid KML strings only.
/// No SSH. No state. No Flutter dependencies.
import '../interfaces/i_kml_builder.dart';

class KmlBuilder implements IKmlBuilder {
  static const int _maxPayloadSize = 100 * 1024; // 100 KB safeguard

  // ─────────────────────────────────────────────────────────────
  // BUILD COLORED 3D PYRAMID  (full KML document)
  // ─────────────────────────────────────────────────────────────
  @override
  String buildColoredPyramid({
    required double latitude,
    required double longitude,
    required double height,
  }) {
    // Angular offset: 0.0008° ≈ 80 m side length — clearly visible at 500 m range
    const double o = 0.0008;

    final double lonW = longitude;
    final double lonE = longitude + o;
    final double latS = latitude;
    final double latN = latitude + o;
    final double lonC = longitude + o / 2;
    final double latC = latitude  + o / 2;

    // Four base corners at ground level (altitude = 0)
    final sw   = '$lonW,$latS,0';
    final se   = '$lonE,$latS,0';
    final ne   = '$lonE,$latN,0';
    final nw   = '$lonW,$latN,0';

    // Apex at the centre, elevated to full height
    final apex = '$lonC,$latC,$height';

    final kml = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
  <n>3D Pyramid</n>

  <Style id="styleSouth">
    <PolyStyle><color>cc0000ff</color><fill>1</fill><outline>1</outline></PolyStyle>
    <LineStyle><color>ff000000</color><width>1.5</width></LineStyle>
  </Style>
  <Style id="styleEast">
    <PolyStyle><color>cc00aa00</color><fill>1</fill><outline>1</outline></PolyStyle>
    <LineStyle><color>ff000000</color><width>1.5</width></LineStyle>
  </Style>
  <Style id="styleNorth">
    <PolyStyle><color>ccff5500</color><fill>1</fill><outline>1</outline></PolyStyle>
    <LineStyle><color>ff000000</color><width>1.5</width></LineStyle>
  </Style>
  <Style id="styleWest">
    <PolyStyle><color>ccee00ee</color><fill>1</fill><outline>1</outline></PolyStyle>
    <LineStyle><color>ff000000</color><width>1.5</width></LineStyle>
  </Style>
  <Style id="styleBase">
    <PolyStyle><color>99ffffff</color><fill>1</fill><outline>1</outline></PolyStyle>
    <LineStyle><color>ff000000</color><width>1</width></LineStyle>
  </Style>

  <!-- South face: red (SW → SE → apex) -->
  <Placemark>
    <n>South Face</n>
    <styleUrl>#styleSouth</styleUrl>
    <Polygon>
      <altitudeMode>relativeToGround</altitudeMode>
      <outerBoundaryIs><LinearRing><coordinates>
        $sw $se $apex $sw
      </coordinates></LinearRing></outerBoundaryIs>
    </Polygon>
  </Placemark>

  <!-- East face: green (SE → NE → apex) -->
  <Placemark>
    <n>East Face</n>
    <styleUrl>#styleEast</styleUrl>
    <Polygon>
      <altitudeMode>relativeToGround</altitudeMode>
      <outerBoundaryIs><LinearRing><coordinates>
        $se $ne $apex $se
      </coordinates></LinearRing></outerBoundaryIs>
    </Polygon>
  </Placemark>

  <!-- North face: orange (NE → NW → apex) -->
  <Placemark>
    <n>North Face</n>
    <styleUrl>#styleNorth</styleUrl>
    <Polygon>
      <altitudeMode>relativeToGround</altitudeMode>
      <outerBoundaryIs><LinearRing><coordinates>
        $ne $nw $apex $ne
      </coordinates></LinearRing></outerBoundaryIs>
    </Polygon>
  </Placemark>

  <!-- West face: purple (NW → SW → apex) -->
  <Placemark>
    <n>West Face</n>
    <styleUrl>#styleWest</styleUrl>
    <Polygon>
      <altitudeMode>relativeToGround</altitudeMode>
      <outerBoundaryIs><LinearRing><coordinates>
        $nw $sw $apex $nw
      </coordinates></LinearRing></outerBoundaryIs>
    </Polygon>
  </Placemark>

  <!-- Base: semi-transparent white square on ground -->
  <Placemark>
    <n>Base</n>
    <styleUrl>#styleBase</styleUrl>
    <Polygon>
      <altitudeMode>relativeToGround</altitudeMode>
      <outerBoundaryIs><LinearRing><coordinates>
        $sw $se $ne $nw $sw
      </coordinates></LinearRing></outerBoundaryIs>
    </Polygon>
  </Placemark>

</Document>
</kml>''';

    _validatePayload(kml);
    return kml;
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD SCREEN OVERLAY  (full KML document)
  // ─────────────────────────────────────────────────────────────
  @override
  String buildScreenOverlay({
    required String imageUrl,
    required double x,
    required double y,
    required double width,
    required double height,
  }) {
    if (imageUrl.isEmpty) throw ArgumentError('Image URL cannot be empty.');

    final safeX = x.clamp(0.05, 0.95);
    final safeY = y.clamp(0.05, 0.95);

    final kml = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
  <ScreenOverlay>
    <n>Logo</n>
    <Icon>
      <href>https://raw.githubusercontent.com/lucisays/imagen/main/LGMasterWebAppLogo.png</href>
    </Icon>
    <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
    <screenXY x="$safeX" y="$safeY" xunits="fraction" yunits="fraction"/>
    <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
    <size x="$width" y="$height" xunits="fraction" yunits="fraction"/>
  </ScreenOverlay>
</Document>
</kml>''';

    _validatePayload(kml);
    return kml;
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD FLY-TO  (bare LookAt fragment — NOT a full KML document)
  // ─────────────────────────────────────────────────────────────
  @override
  String buildFlyTo({
    required double latitude,
    required double longitude,
    required double zoom,
    required double tilt,
    required double bearing,
  }) {
    return '<LookAt>'
        '<longitude>$longitude</longitude>'
        '<latitude>$latitude</latitude>'
        '<altitude>0</altitude>'
        '<heading>$bearing</heading>'
        '<tilt>$tilt</tilt>'
        '<range>$zoom</range>'
        '<altitudeMode>relativeToGround</altitudeMode>'
        '</LookAt>';
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD WEATHER PLACEMARK  (full KML document)
  // ─────────────────────────────────────────────────────────────
  @override
  String buildWeatherPlacemark({
    required String cityName,
    required double latitude,
    required double longitude,
    required double temperatureC,
    required int weatherCode,
    required double windspeedKmh,
  }) {
    final kml = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
  <n>Weather</n>
  <Placemark>
    <n>$cityName</n>
    <description>
      <![CDATA[
        <b>Temperature:</b> ${temperatureC.toStringAsFixed(1)}°C<br/>
        <b>Wind Speed:</b> ${windspeedKmh.toStringAsFixed(1)} km/h<br/>
        <b>Weather Code:</b> $weatherCode
      ]]>
    </description>
    <Point>
      <coordinates>$longitude,$latitude,0</coordinates>
    </Point>
  </Placemark>
</Document>
</kml>''';

    _validatePayload(kml);
    return kml;
  }

  // ─────────────────────────────────────────────────────────────
  // INTERNAL PAYLOAD GUARD
  // ─────────────────────────────────────────────────────────────
  void _validatePayload(String kml) {
    if (kml.trim().isEmpty) throw StateError('Generated KML is empty.');
    if (kml.length > _maxPayloadSize) {
      throw StateError('KML payload exceeds $_maxPayloadSize byte limit.');
    }
  }
}