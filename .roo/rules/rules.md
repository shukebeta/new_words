
- When displaying SnackBars, check if the code uses the showInfo or showError methods from lib/utils/util.dart instead of directly using ScaffoldMessenger.of(context).showSnackBar. If direct usage of ScaffoldMessenger.of(context).showSnackBar is found, suggest using the showInfo or showError methods instead.
