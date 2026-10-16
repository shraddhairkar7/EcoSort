import 'package:ecosort/models/bin.dart';
import 'package:ecosort/models/waste_item.dart';

/// Static lookup table for the Waste Sorting Helper.
/// Students can add rows here without touching UI code.
const List<WasteItem> kWasteCatalogue = [
  WasteItem(
    name: 'Banana peel',
    aliases: ['fruit', 'peel', 'organic'],
    binType: BinType.wet,
    tip: 'All fruit/veg scraps go in the wet/organic bin for composting.',
  ),
  WasteItem(
    name: 'Tea bags',
    aliases: ['chai', 'coffee grounds'],
    binType: BinType.wet,
    tip: 'Remove any plastic staple. Leaves and paper bags are wet waste.',
  ),
  WasteItem(
    name: 'Leftover food',
    aliases: ['rice', 'curry', 'spoiled'],
    binType: BinType.wet,
    tip: 'Never mix leftovers with dry recyclables — it contaminates a whole bag.',
  ),
  WasteItem(
    name: 'Newspaper',
    aliases: ['paper', 'magazine'],
    binType: BinType.recyclable,
    tip: 'Keep paper dry. Soiled pizza boxes are dry waste, not recyclable.',
  ),
  WasteItem(
    name: 'Cardboard box',
    aliases: ['carton', 'amazon box'],
    binType: BinType.recyclable,
    tip: 'Flatten the box. Remove plastic tape if you can.',
  ),
  WasteItem(
    name: 'Plastic water bottle',
    aliases: ['pet', 'bottle'],
    binType: BinType.recyclable,
    tip: 'Empty and crush. Caps can stay on in most Indian MRFs.',
  ),
  WasteItem(
    name: 'Glass jar',
    aliases: ['bottle glass'],
    binType: BinType.recyclable,
    tip: 'Rinse. Broken glass should be wrapped and marked — still recyclable.',
  ),
  WasteItem(
    name: 'Aluminium can',
    aliases: ['tin', 'soda', 'cold drink'],
    binType: BinType.recyclable,
    tip: 'Cans are high-value recyclables. Rinse to avoid pests.',
  ),
  WasteItem(
    name: 'Chip packet',
    aliases: ['kurkure', 'lays', 'wrapper'],
    binType: BinType.dry,
    tip: 'Metallised snack wrappers are NOT recyclable in most cities.',
  ),
  WasteItem(
    name: 'Broken ceramic mug',
    aliases: ['cup', 'plate'],
    binType: BinType.dry,
    tip: 'Ceramics are dry waste, not glass recycling.',
  ),
  WasteItem(
    name: 'Used tissue',
    aliases: ['napkin', 'kitchen towel'],
    binType: BinType.wet,
    tip: 'Soiled paper that cannot be recycled counts as wet/soiled.',
  ),
  WasteItem(
    name: 'Battery',
    aliases: ['cell', 'aa', 'lithium'],
    binType: BinType.general,
    tip: 'E-waste! Do not bin it. Take it to the campus e-waste drop (demo: general).',
  ),
  WasteItem(
    name: 'Phone charger',
    aliases: ['cable', 'wire', 'ewaste'],
    binType: BinType.general,
    tip: 'Electronic waste — campus e-waste drive, not the recyclable bin.',
  ),
  WasteItem(
    name: 'Milk packet',
    aliases: ['pouch', 'dairy'],
    binType: BinType.dry,
    tip: 'Rinse the plastic pouch; it is dry waste in many municipal rules.',
  ),
  WasteItem(
    name: 'Coconut shell',
    aliases: ['nariyal'],
    binType: BinType.dry,
    tip: 'Hard shells are dry; coconut coir/flesh is wet.',
  ),
  WasteItem(
    name: 'Garden leaves',
    aliases: ['twigs', 'flowers'],
    binType: BinType.wet,
    tip: 'Green waste composts well — keep plastic bags out of it.',
  ),
  WasteItem(
    name: 'Styrofoam cup',
    aliases: ['thermocol', 'foam'],
    binType: BinType.dry,
    tip: 'Expanded polystyrene is rarely recycled locally.',
  ),
  WasteItem(
    name: 'Medicine strip',
    aliases: ['tablet', 'pill foil'],
    binType: BinType.dry,
    tip: 'Foil blister packs are dry waste. Expired meds: pharmacy take-back.',
  ),
  WasteItem(
    name: 'Old clothes',
    aliases: ['shirt', 'textile'],
    binType: BinType.dry,
    tip: 'Donate if usable. Torn textiles are dry waste.',
  ),
  WasteItem(
    name: 'Pen',
    aliases: ['ballpen', 'marker'],
    binType: BinType.dry,
    tip: 'Small plastic stationery is dry waste.',
  ),
];
