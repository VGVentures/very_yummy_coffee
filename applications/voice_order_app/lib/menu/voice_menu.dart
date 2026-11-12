import 'package:very_yummy_coffee_voice_order_app/menu/menu_drink.dart';

/// The drinks that can be ordered by voice.
///
/// Names, prices and photos mirror `api/fixtures/menu.json`. Items that are
/// only a variation of another drink ("Iced Latte", "Oat Milk Latte") are
/// left out because milk and temperature are options here.
abstract final class VoiceMenu {
  static const maxShots = 4;

  static const drinks = <MenuDrink>[
    MenuDrink(
      id: 'espresso',
      name: 'Espresso',
      priceCents: 350,
      imageUrl: '$_images/SBX20190617_Espresso_Single$_crop',
      defaultShots: 1,
    ),
    MenuDrink(
      id: 'americano',
      name: 'Americano',
      priceCents: 425,
      imageUrl: '$_images/CaffeAmericano$_crop',
      icedImageUrl: '$_images/IcedCaffeAmericano$_crop',
      defaultShots: 2,
    ),
    MenuDrink(
      id: 'cortado',
      name: 'Cortado',
      priceCents: 475,
      imageUrl: '$_images/Cortado$_crop',
      defaultShots: 2,
      defaultMilk: Milk.whole,
    ),
    MenuDrink(
      id: 'macchiato',
      name: 'Macchiato',
      priceCents: 450,
      imageUrl: '$_images/SBX20190617_EspressoMacchiato$_crop',
      defaultShots: 2,
      defaultMilk: Milk.whole,
    ),
    MenuDrink(
      id: 'flat_white',
      name: 'Flat White',
      priceCents: 550,
      imageUrl: '$_images/SBX20230406_FlatWhite$_crop',
      defaultShots: 2,
      defaultMilk: Milk.whole,
    ),
    MenuDrink(
      id: 'latte',
      name: 'Latte',
      priceCents: 525,
      imageUrl: '$_images/CaffeLatte$_crop',
      icedImageUrl: '$_images/IcedCaffeLatte$_crop',
      defaultShots: 2,
      defaultMilk: Milk.whole,
    ),
    MenuDrink(
      id: 'cappuccino',
      name: 'Cappuccino',
      priceCents: 525,
      imageUrl: '$_images/Cappuccino$_crop',
      defaultShots: 2,
      defaultMilk: Milk.whole,
    ),
    MenuDrink(
      id: 'mocha',
      name: 'Mocha',
      priceCents: 575,
      imageUrl: '$_images/SBX20220607_CaffeMocha$_crop',
      defaultShots: 2,
      defaultMilk: Milk.whole,
    ),
    MenuDrink(
      id: 'vanilla_latte',
      name: 'Vanilla Latte',
      priceCents: 575,
      imageUrl: '$_images/BlondeVanillaLatte$_crop',
      defaultShots: 2,
      defaultMilk: Milk.whole,
    ),
    MenuDrink(
      id: 'cold_brew',
      name: 'Cold Brew',
      priceCents: 475,
      imageUrl: '$_images/ColdBrew$_crop',
      defaultTemperature: Temperature.iced,
    ),
    MenuDrink(
      id: 'nitro_cold_brew',
      name: 'Nitro Cold Brew',
      priceCents: 550,
      imageUrl: '$_images/NitroColdBrew$_crop',
      defaultTemperature: Temperature.iced,
    ),
    MenuDrink(
      id: 'matcha_latte',
      name: 'Matcha Latte',
      priceCents: 575,
      imageUrl: '$_images/SBX20211115_MatchaTeaLatte$_crop',
      defaultMilk: Milk.whole,
    ),
    MenuDrink(
      id: 'chai_latte',
      name: 'Chai Latte',
      priceCents: 500,
      imageUrl: '$_images/SBX20220411_ChaiLatte$_crop',
      defaultMilk: Milk.whole,
    ),
    MenuDrink(
      id: 'earl_grey',
      name: 'Earl Grey',
      priceCents: 375,
      imageUrl: '$_images/SBX20190624_EarlGreyBlackTea$_crop',
    ),
    MenuDrink(
      id: 'green_tea',
      name: 'Green Tea',
      priceCents: 350,
      imageUrl: '$_images/EmperorCloudsAndMistTea$_crop',
    ),
    MenuDrink(
      id: 'hot_chocolate',
      name: 'Hot Chocolate',
      priceCents: 475,
      imageUrl: '$_images/HotChocolate$_crop',
      defaultMilk: Milk.whole,
    ),
    MenuDrink(
      id: 'lemonade',
      name: 'Lemonade',
      priceCents: 425,
      imageUrl: '$_images/SBX20190624_Lemonade$_crop',
      defaultTemperature: Temperature.iced,
    ),
  ];

  static MenuDrink? byId(String id) {
    for (final drink in drinks) {
      if (drink.id == id) return drink;
    }
    return null;
  }

  static const _images = 'https://cloudassets.starbucks.com/is/image/sbuxcorp';
  static const _crop =
      '?impolicy=1by1_wide_topcrop_630&crop=180,360,1440,1440'
      '&wid=630&hei=630&qlt=85';
}
