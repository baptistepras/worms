#!/usr/bin/env python3
# plot_trajectory.py

import sys
import matplotlib.pyplot as plt

def read_dxdy(filename):
    """
    Lit un fichier où chaque ligne est 'dx dy'
    et renvoie un itérateur de tuples (dx, dy) en float.
    On ignore les lignes vides et celles qui ne contiennent pas deux valeurs.
    """
    with open(filename, 'r') as f:
        for lineno, line in enumerate(f, 1):
            parts = line.strip().split()
            if not parts or len(parts) < 2:
                continue
            try:
                dx, dy = float(parts[0]), float(parts[1])
                yield dx, dy
            except ValueError:
                # on ignore les lignes mal formées
                print(f"Ignored bad line {lineno}: {line.strip()}", file=sys.stderr)

def build_trajectory(dxdy_iter):
    """
    A partir d'un itérateur (dx, dy),
    construit deux listes xs et ys de positions cumulées.
    """
    x, y = 0.0, 0.0
    xs = [x]
    ys = [y]
    for dx, dy in dxdy_iter:
        x += dx
        y += dy
        xs.append(x)
        ys.append(y)
    return xs, ys

def plot(xs, ys):
    plt.figure(figsize=(8,6))
    plt.plot(xs, ys, marker='o', linestyle='-')
    plt.title("Trajectoire reconstituée à partir de dx, dy")
    plt.xlabel("x cumulés")
    plt.ylabel("y cumulés")
    plt.grid(True)
    plt.axis('equal')  # conserve les proportions
    plt.show()

def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} file.txt", file=sys.stderr)

    fichier ="file.txt"
    dxdy_iter = read_dxdy(fichier)
    xs, ys   = build_trajectory(dxdy_iter)
    plot(xs, ys)

if __name__ == "__main__":
    main()