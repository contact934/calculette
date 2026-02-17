import Calculette from "@/components/Calculette";

export const metadata = {
  title: "Calculette Écotaxe & Carte Grise",
  description:
    "Simulateur malus CO₂, taxe au poids et coût total carte grise — Barèmes NEDC/WLTP, Loi de finances 2025, 101 départements.",
};

export default function CalculettePage() {
  return <Calculette />;
}
