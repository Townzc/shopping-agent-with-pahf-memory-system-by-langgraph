import { useCallback, useEffect, useMemo, useState } from "react";
import type { FormEvent, ReactNode } from "react";
import type { Conversation } from "./shopTypes";
import {
  fetchAdminConversations,
  fetchAdminMe,
  fetchAdminOverview,
  fetchAdminProducts,
  fetchAdminRatings,
  fetchAdminUsers,
  loginAdmin,
  logoutAdmin,
} from "./shopApi";
import type { AdminOverview, AdminProduct, AdminRating, AdminUser } from "./shopApi";

const TOKEN_KEY = "servicebot_admin_token";
type AdminTab = "overview" | "conversations" | "products" | "feedback" | "users";

const STATUS_LABEL: Record<string, string> = {
  bot: "AI 接待",
  queued: "待人工",
  human: "人工中",
  resolved: "已完结",
};

const ORDER_STATUS_LABEL: Record<string, string> = {
  pending_payment: "待付款",
  shipped: "已发货",
  delivered: "已签收",
};

function money(n: number): string {
  return `¥${n.toLocaleString("zh-CN", { maximumFractionDigits: 0 })}`;
}

function formatTime(ts?: number | null): string {
  if (!ts) return "-";
  return new Date(ts * 1000).toLocaleString("zh-CN", { hour12: false });
}

function stars(n: number): string {
  return "★★★★★".slice(0, n) + "☆☆☆☆☆".slice(0, Math.max(0, 5 - n));
}

function Metric({ label, value, note }: { label: string; value: string | number; note?: string }) {
  return (
    <div className="admin-metric">
      <span>{label}</span>
      <strong>{value}</strong>
      {note && <small>{note}</small>}
    </div>
  );
}

function StatusPill({ status }: { status: string }) {
  return <span className={`admin-status status-${status}`}>{STATUS_LABEL[status] ?? status}</span>;
}

export default function AdminDashboard() {
  const [token, setToken] = useState(() =>
    typeof window === "undefined" ? "" : window.localStorage.getItem(TOKEN_KEY) ?? ""
  );
  const [user, setUser] = useState<AdminUser | null>(null);
  const [username, setUsername] = useState("admin");
  const [password, setPassword] = useState("admin123456");
  const [activeTab, setActiveTab] = useState<AdminTab>("overview");
  const [statusFilter, setStatusFilter] = useState("all");
  const [overview, setOverview] = useState<AdminOverview | null>(null);
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [products, setProducts] = useState<AdminProduct[]>([]);
  const [ratings, setRatings] = useState<AdminRating[]>([]);
  const [users, setUsers] = useState<AdminUser[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const loadDashboard = useCallback(
    async (authToken: string, filter = statusFilter) => {
      setLoading(true);
      setError("");
      try {
        const [me, nextOverview, nextConversations, nextProducts, nextRatings, nextUsers] = await Promise.all([
          fetchAdminMe(authToken),
          fetchAdminOverview(authToken),
          fetchAdminConversations(authToken, filter),
          fetchAdminProducts(authToken),
          fetchAdminRatings(authToken),
          fetchAdminUsers(authToken),
        ]);
        setUser(me.user);
        setOverview(nextOverview);
        setConversations(nextConversations);
        setProducts(nextProducts);
        setRatings(nextRatings);
        setUsers(nextUsers);
      } catch (err) {
        const message = err instanceof Error ? err.message : "后台数据加载失败";
        setError(message);
        if (message.includes("401")) {
          window.localStorage.removeItem(TOKEN_KEY);
          setToken("");
        }
      } finally {
        setLoading(false);
      }
    },
    [statusFilter]
  );

  useEffect(() => {
    if (token) void loadDashboard(token);
  }, [token, loadDashboard]);

  useEffect(() => {
    if (!token) return;
    fetchAdminConversations(token, statusFilter).then(setConversations).catch(() => undefined);
  }, [statusFilter, token]);

  const satisfaction = useMemo(() => {
    const value = overview?.feedback.messages.satisfaction;
    return value == null ? "-" : `${Math.round(value * 100)}%`;
  }, [overview]);

  const handleLogin = async (event: FormEvent) => {
    event.preventDefault();
    setLoading(true);
    setError("");
    try {
      const session = await loginAdmin(username.trim(), password);
      window.localStorage.setItem(TOKEN_KEY, session.access_token);
      setToken(session.access_token);
      setUser(session.user);
    } catch (err) {
      setError(err instanceof Error ? err.message : "登录失败");
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = async () => {
    if (token) {
      await logoutAdmin(token).catch(() => undefined);
    }
    window.localStorage.removeItem(TOKEN_KEY);
    setToken("");
    setUser(null);
    setOverview(null);
  };

  if (!token) {
    return (
      <main className="admin-shell admin-login-shell">
        <form className="admin-login" onSubmit={handleLogin}>
          <div>
            <p className="admin-kicker">Backoffice</p>
            <h1>电商售后客服后台</h1>
          </div>
          <label>
            账号
            <input value={username} onChange={(e) => setUsername(e.target.value)} autoComplete="username" />
          </label>
          <label>
            密码
            <input
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              type="password"
              autoComplete="current-password"
            />
          </label>
          {error && <div className="admin-alert">{error}</div>}
          <button className="primary wide" disabled={loading}>
            {loading ? "登录中..." : "登录"}
          </button>
          <p className="admin-demo-account">演示账号：admin / admin123456</p>
        </form>
      </main>
    );
  }

  return (
    <main className="admin-shell">
      <header className="admin-topbar">
        <div>
          <p className="admin-kicker">Backoffice</p>
          <h1>电商售后客服与评价分析后台</h1>
        </div>
        <div className="admin-account">
          <span>{user?.display_name ?? user?.username ?? "管理员"}</span>
          <button onClick={() => loadDashboard(token)} disabled={loading}>
            刷新
          </button>
          <button onClick={handleLogout}>退出</button>
        </div>
      </header>

      {error && <div className="admin-alert">{error}</div>}

      <nav className="admin-tabs">
        {[
          ["overview", "总览"],
          ["conversations", "会话"],
          ["products", "商品"],
          ["feedback", "评价"],
          ["users", "账号"],
        ].map(([key, label]) => (
          <button
            key={key}
            className={activeTab === key ? "active" : ""}
            onClick={() => setActiveTab(key as AdminTab)}
          >
            {label}
          </button>
        ))}
      </nav>

      {activeTab === "overview" && (
        <section className="admin-view">
          <div className="admin-metrics">
            <Metric label="商品" value={overview?.catalog.active_products ?? "-"} note={`SKU ${overview?.catalog.skus ?? 0}`} />
            <Metric label="订单" value={overview?.catalog.orders ?? "-"} note={money(overview?.catalog.revenue ?? 0)} />
            <Metric
              label="会话"
              value={overview?.conversations.total ?? "-"}
              note={`待人工 ${overview?.conversations.by_status.queued ?? 0}`}
            />
            <Metric label="平均评分" value={overview?.feedback.ratings.avg_stars || "-"} note={`${overview?.feedback.ratings.count ?? 0} 条`} />
            <Metric label="消息满意度" value={satisfaction} note={`${overview?.feedback.messages.total ?? 0} 次反馈`} />
            <Metric label="在线坐席" value={overview?.agents.online_agents ?? 0} note={`账号 ${users.length}`} />
          </div>

          <div className="admin-layout two">
            <section className="admin-panel">
              <div className="admin-section-head">
                <h2>会话状态</h2>
                <span>{formatTime(overview?.generated_at)}</span>
              </div>
              <div className="admin-status-grid">
                {["bot", "queued", "human", "resolved"].map((status) => (
                  <div key={status}>
                    <StatusPill status={status} />
                    <strong>{overview?.conversations.by_status[status] ?? 0}</strong>
                  </div>
                ))}
              </div>
            </section>

            <section className="admin-panel">
              <div className="admin-section-head">
                <h2>库存与订单</h2>
                <span>低库存 SKU {overview?.catalog.low_stock_skus ?? 0}</span>
              </div>
              <div className="admin-bars">
                {Object.entries(overview?.catalog.orders_by_status ?? {}).map(([status, count]) => (
                  <div key={status} className="admin-bar-row">
                    <span>{ORDER_STATUS_LABEL[status] ?? status}</span>
                    <div>
                      <i style={{ width: `${Math.max(8, count * 22)}px` }} />
                    </div>
                    <b>{count}</b>
                  </div>
                ))}
              </div>
            </section>
          </div>

          <div className="admin-layout two">
            <section className="admin-panel">
              <div className="admin-section-head">
                <h2>商品分类</h2>
                <span>库存 {overview?.catalog.total_stock ?? 0}</span>
              </div>
              <div className="admin-category-list">
                {(overview?.catalog.categories ?? []).map((item) => (
                  <div key={item.category}>
                    <span>{item.category}</span>
                    <strong>{item.count}</strong>
                  </div>
                ))}
              </div>
            </section>

            <section className="admin-panel">
              <div className="admin-section-head">
                <h2>最近会话</h2>
                <button onClick={() => setActiveTab("conversations")}>查看</button>
              </div>
              <div className="admin-mini-list">
                {(overview?.conversations.latest ?? []).map((item) => (
                  <div key={item.conversation_id}>
                    <span>{item.customer_id}</span>
                    <StatusPill status={item.status} />
                    <small>{formatTime(item.last_message_at)}</small>
                  </div>
                ))}
              </div>
            </section>
          </div>
        </section>
      )}

      {activeTab === "conversations" && (
        <section className="admin-view">
          <div className="admin-section-head">
            <h2>会话管理</h2>
            <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)}>
              <option value="all">全部</option>
              <option value="bot">AI 接待</option>
              <option value="queued">待人工</option>
              <option value="human">人工中</option>
              <option value="resolved">已完结</option>
            </select>
          </div>
          <AdminTable
            columns={["会话ID", "客户", "状态", "优先级", "坐席", "CSAT", "最后消息"]}
            rows={conversations.map((item) => [
              item.conversation_id,
              item.customer_id,
              <StatusPill status={item.status} />,
              item.priority,
              item.assigned_agent || "-",
              item.csat ?? "-",
              formatTime(item.last_message_at),
            ])}
          />
        </section>
      )}

      {activeTab === "products" && (
        <section className="admin-view">
          <div className="admin-section-head">
            <h2>商品与库存</h2>
            <span>{products.length} 个商品</span>
          </div>
          <AdminTable
            columns={["商品ID", "名称", "分类", "品牌", "价格", "SKU", "库存", "状态"]}
            rows={products.map((item) => [
              item.product_id,
              item.title,
              item.category,
              item.brand,
              money(item.price),
              item.sku_count,
              item.stock_total,
              item.status,
            ])}
          />
        </section>
      )}

      {activeTab === "feedback" && (
        <section className="admin-view">
          <div className="admin-section-head">
            <h2>用户评价分析</h2>
            <span>平均 {overview?.feedback.ratings.avg_stars ?? 0} 分</span>
          </div>
          <div className="admin-feedback-band">
            {[5, 4, 3, 2, 1].map((score) => (
              <div key={score}>
                <span>{score} 星</span>
                <strong>{overview?.feedback.ratings.distribution[String(score)] ?? 0}</strong>
              </div>
            ))}
            {(overview?.feedback.top_tags ?? []).map((tag) => (
              <div key={tag.tag}>
                <span>{tag.tag}</span>
                <strong>{tag.count}</strong>
              </div>
            ))}
          </div>
          <AdminTable
            columns={["会话ID", "客户", "评分", "标签", "评论", "时间"]}
            rows={ratings.map((item) => [
              item.conversation_id,
              item.customer_id,
              stars(item.stars),
              item.tags.join("、") || "-",
              item.comment || "-",
              formatTime(item.created_at),
            ])}
          />
        </section>
      )}

      {activeTab === "users" && (
        <section className="admin-view">
          <div className="admin-section-head">
            <h2>管理员账号</h2>
            <span>{users.length} 个账号</span>
          </div>
          <AdminTable
            columns={["账号", "显示名", "角色", "创建时间", "最近登录"]}
            rows={users.map((item) => [
              item.username,
              item.display_name,
              item.role,
              formatTime(item.created_at),
              formatTime(item.last_login_at),
            ])}
          />
        </section>
      )}
    </main>
  );
}

function AdminTable({ columns, rows }: { columns: string[]; rows: Array<Array<ReactNode>> }) {
  return (
    <div className="admin-table-wrap">
      <table className="admin-table">
        <thead>
          <tr>
            {columns.map((column) => (
              <th key={column}>{column}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.length === 0 ? (
            <tr>
              <td colSpan={columns.length} className="admin-empty">
                暂无数据
              </td>
            </tr>
          ) : (
            rows.map((row, idx) => (
              <tr key={idx}>
                {row.map((cell, cellIdx) => (
                  <td key={cellIdx}>{cell}</td>
                ))}
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
}
