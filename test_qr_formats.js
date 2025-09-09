const fs = require('fs');

// Simular os dois formatos de QR Code
const qrFormats = {
  // Formato do backend (string simples)
  backend: 'delivery_confirm:618bfadf-e2e8-4bf1-8a02-5c43b68ac843:abc123def456',
  
  // Formato do cliente (JSON)
  client: JSON.stringify({
    order_id: '618bfadf-e2e8-4bf1-8a02-5c43b68ac843',
    timestamp: Date.now(),
    type: 'delivery_confirmation',
    hash: 'abc123def456'
  })
};

console.log('🧪 Testando formatos de QR Code:');
console.log('\n📱 Formato Backend (string):');
console.log(qrFormats.backend);
console.log('\n📱 Formato Cliente (JSON):');
console.log(qrFormats.client);

// Simular a lógica de parsing do Flutter
function parseQRCode(qrData) {
  let orderId = null;
  let confirmationCode = null;
  
  // Tentar primeiro o formato JSON (cliente)
  try {
    const qrPayload = JSON.parse(qrData);
    
    // Validar estrutura do QR Code JSON
    if (qrPayload.order_id &&
        qrPayload.type &&
        qrPayload.type === 'delivery_confirmation') {
      orderId = qrPayload.order_id;
      confirmationCode = qrPayload.hash;
      return { orderId, confirmationCode, format: 'JSON' };
    }
  } catch (e) {
    // Se não for JSON, tentar formato string (backend)
    if (qrData.startsWith('delivery_confirm:')) {
      const parts = qrData.split(':');
      if (parts.length === 3) {
        orderId = parts[1];
        confirmationCode = parts[2];
        return { orderId, confirmationCode, format: 'STRING' };
      }
    }
  }
  
  return null;
}

console.log('\n🔍 Testando parsing:');

// Testar formato backend
const backendResult = parseQRCode(qrFormats.backend);
console.log('\n✅ Formato Backend:', backendResult);

// Testar formato cliente
const clientResult = parseQRCode(qrFormats.client);
console.log('✅ Formato Cliente:', clientResult);

// Testar formato inválido
const invalidResult = parseQRCode('invalid_qr_code');
console.log('❌ Formato Inválido:', invalidResult);

console.log('\n🎉 Teste de formatos concluído!');