import 'package:flutter/material.dart';
import 'package:meals/data/dummy_data.dart';
import 'package:meals/screens/categories.dart';
import 'package:meals/screens/filter.dart';
import 'package:meals/screens/meals.dart';
import 'package:meals/model/meal.dart';
import 'package:meals/widgets/main_drawer.dart';

const selectedMeal = {
  Filter.gluttenFree: false,
  Filter.lactoseFree: false,
  Filter.vegetarian: false,
  Filter.vegan: false,
};

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});
  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> {
  // var _selectedMeals = resu
  Map<Filter, bool> _selectedMeal = selectedMeal;
  int _selectedPageIndex = 0;
  final List<Meal> mealFavorites = [];

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void showInfoMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _toggleFavorites(Meal meal) {
    final isFavorite = mealFavorites.contains(meal);

    if (isFavorite) {
      setState(() {
        mealFavorites.remove(meal);
      });
      showInfoMessage('Meal removed from favorites');
    } else {
      setState(() {
        mealFavorites.add(meal);
      });
      showInfoMessage('Added to favorites!');
    }
  }

  void selectScreen(String screen) async {
    Navigator.of(context).pop();
    if (screen == 'Filter') {
      final result = await Navigator.of(context).push<Map<Filter, bool>>(
        MaterialPageRoute(
          builder: ((ctx) => FilterScreen(
                filterSet: _selectedMeal,
              )),
        ),
      );
      setState(() {
        _selectedMeal = result ?? selectedMeal;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final avaialbleMeals = dummyMeals.where((meal) {
      if (_selectedMeal[Filter.gluttenFree]! && !meal.isGlutenFree) {
        return false;
      }
      if (_selectedMeal[Filter.lactoseFree]! && !meal.isLactoseFree) {
        return false;
      }
      if (_selectedMeal[Filter.vegetarian]! && !meal.isVegetarian) {
        return false;
      }
      if (_selectedMeal[Filter.vegan]! && !meal.isVegan) {
        return false;
      }
      return true;
    }).toList();

    Widget activePage = CategoriesScreen(
      onToggleFavorite: _toggleFavorites,
      availableMeals: avaialbleMeals,
    );
    var activePageTitle = 'Categories';

    if (_selectedPageIndex == 1) {
      activePage =
          MealsScreen(meals: mealFavorites, onToggleFavorite: _toggleFavorites);
      activePageTitle = 'Favorites';
    }

    return Scaffold(
      appBar: AppBar(title: Text(activePageTitle)),
      drawer: MainDrawer(onSelectScreen: selectScreen),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.set_meal), label: 'Categories'),
          BottomNavigationBarItem(
              icon: Icon(Icons.star), label: 'Your Favorites'),
        ],
      ),
    );
  }
}
