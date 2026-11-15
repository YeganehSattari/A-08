# card.py - prints an English business card with an aligned ASCII frame.
# Change only the four variables below; the frame resizes itself.

name = "Sara Ahmadi"
track = "ALPHA - Agentic AI"
city = "Tehran"
motto = "Ship it, then improve it."

# the frame is at least 31 characters wide, or as wide as the longest value
width = max(31, len(name), len(track), len(city), len(motto))
border = "+" + "-" * (width + 9) + "+"

print(border)
print(f"|  {'Name':<5}: {name:<{width}}|")
print(f"|  {'Track':<5}: {track:<{width}}|")
print(f"|  {'City':<5}: {city:<{width}}|")
print(f"|  {'Motto':<5}: {motto:<{width}}|")
print(border)
