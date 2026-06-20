// src/pages/Settings/Settings.jsx

export default function Settings({ toast }) {
  const Section = ({ title, children }) => (
    <div className="card" style={{ marginBottom: 20 }}>
      <div className="card-header"><span className="card-title">{title}</span></div>
      <div className="card-body">{children}</div>
    </div>
  );

  const Field = ({ label, type = 'text', defaultValue, placeholder }) => (
    <div className="form-group">
      <label className="form-label">{label}</label>
      <input className="form-input" type={type} defaultValue={defaultValue} placeholder={placeholder} />
    </div>
  );

  return (
    <div>
      <div className="page-header">
        <div className="page-title">Settings</div>
      </div>

      <div className="grid-2">
        <div>
          <Section title="🌐 API Configuration">
            <Field label="Backend URL"    defaultValue="https://api.fastkart.in" />
            <Field label="API Version"    defaultValue="v1" />
            <Field label="Timeout (sec)"  defaultValue="30" type="number" />
            <button className="btn btn-primary" onClick={() => toast('API settings saved!')}>Save Changes</button>
          </Section>

          <Section title="💳 Payment Keys">
            <Field label="Stripe Secret Key"  type="password" placeholder="sk_live_..." />
            <Field label="Razorpay Key ID"    type="password" placeholder="rzp_live_..." />
            <Field label="Razorpay Secret"    type="password" placeholder="Your secret" />
            <button className="btn btn-primary" onClick={() => toast('Payment keys saved!')}>Update Keys</button>
          </Section>
        </div>

        <div>
          <Section title="🔔 Notification Settings">
            {[
              ['New Order Alerts',  'enabled'],
              ['Low Stock Alerts',  'enabled'],
              ['Revenue Reports',   'weekly'],
              ['Driver Offline Alert', 'enabled'],
              ['Dispute Alerts',    'enabled'],
            ].map(([label, val]) => (
              <div key={label} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '11px 0', borderBottom: '1px solid var(--border)' }}>
                <span style={{ fontSize: 13, fontWeight: 500 }}>{label}</span>
                <select className="form-select-sm">
                  <option>{val === 'weekly' ? 'Weekly' : 'Enabled'}</option>
                  <option>{val === 'weekly' ? 'Daily'  : 'Disabled'}</option>
                  {val === 'weekly' && <option>Monthly</option>}
                </select>
              </div>
            ))}
            <button className="btn btn-primary" style={{ marginTop: 16 }} onClick={() => toast('Notifications settings saved!')}>Save</button>
          </Section>

          <Section title="🛡️ Admin Profile">
            <Field label="Admin Name"  defaultValue="FastKart Admin" />
            <Field label="Email"       defaultValue="admin@fastkart.in" />
            <Field label="New Password" type="password" placeholder="Leave blank to keep current" />
            <button className="btn btn-primary" onClick={() => toast('Profile updated!')}>Update Profile</button>
          </Section>
        </div>
      </div>
    </div>
  );
}