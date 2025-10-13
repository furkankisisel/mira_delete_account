import express from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';

const app = express();
app.use(cors());
app.use(bodyParser.json());

// In-memory veritabanı
const users = new Map(); // userId -> { entitlement, trialStart }
const data = {
    SavingAnalysis: new Map(),
    RecurringEntry: new Map(),
    AdvancedHabit: new Map(),
    BackupRecord: new Map(),
};

function now() { return new Date(); }

app.post('/checkEntitlements', (req, res) => {
    const { userId } = req.body;
    const u = users.get(userId) || { entitlement: 'none' };
    res.json({ entitlement: u.entitlement });
});

app.post('/verifyPurchase', (req, res) => {
    const { userId, platform, productId, receipt } = req.body;
    // NOT: Burada gerçek doğrulama yapılmalıdır:
    // - Google Play Developer API (Purchases.subscriptions)
    // - App Store Server API (verifyTransaction / getSubscriptionStatus)
    // Bu stub, her zaman başarılı kabul eder.
    users.set(userId, { entitlement: 'premium' });
    // Trial verilerini premiuma bağlamak (örnek: isTrialGenerated=false yapılabilir)
    for (const type of Object.keys(data)) {
        for (const [id, rec] of data[type]) {
            if (rec.userId === userId && rec.isTrialGenerated) {
                rec.isTrialGenerated = false;
                data[type].set(id, rec);
            }
        }
    }
    res.json({ ok: true });
});

app.post('/cleanupTrialData', (req, res) => {
    const { userId } = req.body || {};
    let deleted = 0;
    const limit = 1000;
    const cutoff = now();

    const shouldDelete = (rec) => {
        if (!rec.isTrialGenerated) return false;
        const createdAt = new Date(rec.createdAt || rec.created_at || now());
        // Bu stub'da client trial end + 7 kontrolünü yapmadığımız için
        // isTrialGenerated=true kayıtları eskiyse siliyoruz (örnek amaçlı)
        const diffDays = (cutoff - createdAt) / (1000 * 60 * 60 * 24);
        return diffDays > 21; // örnek: 14 + 7
    };

    for (const type of Object.keys(data)) {
        for (const [id, rec] of data[type]) {
            if (userId && rec.userId !== userId) continue;
            if (shouldDelete(rec)) {
                data[type].delete(id);
                deleted++;
                if (deleted >= limit) break;
            }
        }
    }

    res.json({ deleted });
});

app.post('/webhook', (req, res) => {
    const evt = req.body;
    // NOT: Burada RTDN (Google) ve App Store Server Notifications event'leri
    // işlenmeli. refund/cancellation vb. geldiğinde entitlement iptal edilir.
    if (evt.type === 'REFUND' || evt.type === 'CANCEL') {
        const userId = evt.userId;
        const u = users.get(userId) || { entitlement: 'none' };
        u.entitlement = 'none';
        users.set(userId, u);
    }
    res.json({ ok: true });
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Stub backend listening on ${port}`));
