import { 
  Stethoscope, 
  Users, 
  TrendingUp, 
  AlertCircle 
} from "lucide-react";

export default function Dashboard() {
  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-500 mt-2">Welcome back. Here is what is happening with Epidexa today.</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard 
          icon={<Stethoscope className="text-primary" size={24} />}
          label="Total Cases"
          value="24"
          trend="+2 this week"
        />
        <StatCard 
          icon={<Users className="text-blue-600" size={24} />}
          label="Active Students"
          value="156"
          trend="+12% from last month"
        />
        <StatCard 
          icon={<TrendingUp className="text-green-600" size={24} />}
          label="Avg. Score"
          value="82%"
          trend="+3% improvement"
        />
        <StatCard 
          icon={<AlertCircle className="text-orange-600" size={24} />}
          label="Pending Reviews"
          value="5"
          trend="Requires action"
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Recent Activity */}
        <div className="admin-card p-6">
          <h2 className="text-lg font-semibold mb-4">Recent Activity</h2>
          <div className="space-y-4">
            <ActivityItem 
              title="New Case Published"
              description="Case #005: Psoriasis Vulgaris"
              time="2 hours ago"
            />
            <ActivityItem 
              title="Knowledge Base Updated"
              description="Updated treatment guidelines for Atopic Dermatitis"
              time="5 hours ago"
            />
            <ActivityItem 
              title="Bulk Image Upload"
              description="Uploaded 12 high-res dermatology assets"
              time="Yesterday"
            />
          </div>
        </div>

        {/* Quick Actions */}
        <div className="admin-card p-6">
          <h2 className="text-lg font-semibold mb-4">Quick Actions</h2>
          <div className="grid grid-cols-2 gap-4">
            <QuickActionButton label="Create New Case" />
            <QuickActionButton label="Manage Students" />
            <QuickActionButton label="Review Analytics" />
            <QuickActionButton label="System Settings" />
          </div>
        </div>
      </div>
    </div>
  );
}

function StatCard({ icon, label, value, trend }: { icon: React.ReactNode, label: string, value: string, trend: string }) {
  return (
    <div className="admin-card p-6">
      <div className="flex items-center justify-between mb-4">
        <div className="bg-gray-50 p-3 rounded-xl border border-gray-100">
          {icon}
        </div>
      </div>
      <div>
        <p className="text-sm font-medium text-gray-500">{label}</p>
        <h3 className="text-2xl font-bold mt-1">{value}</h3>
        <p className="text-xs text-gray-400 mt-2">{trend}</p>
      </div>
    </div>
  );
}

function ActivityItem({ title, description, time }: { title: string, description: string, time: string }) {
  return (
    <div className="flex gap-4 p-3 rounded-lg hover:bg-gray-50 transition-colors">
      <div className="w-2 h-2 mt-2 rounded-full bg-primary" />
      <div>
        <p className="text-sm font-semibold">{title}</p>
        <p className="text-xs text-gray-500 mt-0.5">{description}</p>
        <p className="text-[10px] text-gray-400 mt-1 uppercase tracking-wider">{time}</p>
      </div>
    </div>
  );
}

function QuickActionButton({ label }: { label: string }) {
  return (
    <button className="flex flex-col items-center justify-center p-4 border border-gray-100 rounded-xl hover:border-primary hover:bg-primary-light transition-all group">
      <span className="text-sm font-medium text-gray-700 group-hover:text-primary">{label}</span>
    </button>
  );
}
