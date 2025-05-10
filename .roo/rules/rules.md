1. When displaying SnackBars, check if the code uses the showInfo or showError methods from lib/utils/util.dart instead of directly using ScaffoldMessenger.of(context).showSnackBar. If direct usage of ScaffoldMessenger.of(context).showSnackBar is found, suggest using the showInfo or showError methods instead.
2. When adding comments to code, ensure they are necessary and meaningful:
	1. Only add comments that explain "why" rather than "what" (the code already shows what)
	2. Avoid redundant comments that simply restate the code
	3. Don't add comments for obvious operations
	4. Focus on comments for complex logic, non-obvious edge cases, or API contracts
