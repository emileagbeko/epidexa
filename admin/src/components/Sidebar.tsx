"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { 
  LayoutDashboard, 
  BookOpen, 
  Image as ImageIcon, 
  Settings, 
  Users,
  LogOut,
  Stethoscope
} from "lucide-react";
import { cn } from "@/lib/utils";

const menuItems = [
  { icon: LayoutDashboard, label: "Overview", href: "/" },
  { icon: Stethoscope, label: "Clinical Cases", href: "/cases" },
  { icon: BookOpen, label: "Knowledge Base", href: "/knowledge" },
  { icon: ImageIcon, label: "Media Assets", href: "/media" },
  { icon: Users, label: "Students", href: "/students" },
];

export function Sidebar() {
  const pathname = usePathname();

  return (
    <div className="flex flex-col w-64 bg-white border-r border-gray-200 h-screen sticky top-0">
      <div className="p-6">
        <div className="flex items-center gap-2 text-primary font-bold text-2xl tracking-tight">
          <div className="bg-primary text-white p-1.5 rounded-lg">
            <Stethoscope size={20} />
          </div>
          Epidexa<span className="text-accent">Admin</span>
        </div>
      </div>

      <nav className="flex-1 px-4 space-y-1">
        {menuItems.map((item) => {
          const isActive = pathname === item.href;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "sidebar-link",
                isActive ? "sidebar-link-active" : "sidebar-link-inactive"
              )}
            >
              <item.icon size={18} />
              {item.label}
            </Link>
          );
        })}
      </nav>

      <div className="p-4 border-t border-gray-200">
        <button className="sidebar-link sidebar-link-inactive w-full">
          <LogOut size={18} />
          Sign Out
        </button>
      </div>
    </div>
  );
}
