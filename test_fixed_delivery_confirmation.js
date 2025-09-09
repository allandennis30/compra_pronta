// Configurar variáveis de ambiente manualmente
process.env.SUPABASE_URL = 'https://feljoannoghnpbqhrsuv.supabase.co';
process.env.SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZlbGpvYW5ub2dobnBicWhyc3V2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ2MjY3ODUsImV4cCI6MjA3MDIwMjc4NX0.uIrk_RMpPaaR2EXSU2YZ-nHvj2Ez5_Wl-3sETF9Tupg';

const https = require('https');
const http = require('http');

/**
 * Função helper para fazer requisições HTTP
 */
function makeRequest(url, options = {}) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url);
    const isHttps = urlObj.protocol === 'https:';
    const client = isHttps ? https : http;
    
    const requestOptions = {
      hostname: urlObj.hostname,
      port: urlObj.port || (isHttps ? 443 : 80),
      path: urlObj.pathname + urlObj.search,
      method: options.method || 'GET',
      headers: options.headers || {}
    };
    
    const req = client.request(requestOptions, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        try {
          const parsedData = JSON.parse(data);
          resolve({
            status: res.statusCode,
            data: parsedData
          });
        } catch (e) {
          resolve({
            status: res.statusCode,
            data: data
          });
        }
      });
    });
    
    req.on('error', (error) => {
      reject({
        message: error.message,
        response: null
      });
    });
    
    if (options.body) {
      req.write(JSON.stringify(options.body));
    }
    
    req.end();
  });
}

/**
 * Teste do endpoint correto de confirmação de entrega
 */
async function testFixedDeliveryConfirmation() {
  try {
    console.log('🧪 [TEST] Testando endpoint correto de confirmação de entrega...');
    
    const baseUrl = 'https://backend-compra-pronta.onrender.com';
    
    // 1. Fazer login como entregador
    console.log('\n1. Fazendo login como entregador...');
    const loginResponse = await makeRequest(`${baseUrl}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: { email: 'kamilly@teste.com', senha: 'teste123' }
    });
    
    if (!loginResponse.data.token) {
      console.error('❌ Falha no login');
      return;
    }
    
    const token = loginResponse.data.token;
    const user = loginResponse.data.user;
    console.log(`✅ Login realizado: ${user.name} (isEntregador: ${user.isEntregador})`);
    
    // 2. Testar com o pedido que tem código de confirmação
    const testOrderId = 'eec7b0b1-4e5a-4e32-bcde-197aa042aa22';
    const testHash = 'test-confirmation-1wu455';
    
    console.log(`\n2. Testando confirmação de entrega...`);
    console.log(`   - Pedido: ${testOrderId}`);
    console.log(`   - Hash: ${testHash}`);
    console.log(`   - QR Code simulado: delivery_confirm:${testOrderId}:${testHash}`);
    
    try {
      const confirmResponse = await makeRequest(
        `${baseUrl}/api/orders/${testOrderId}/confirm-delivery-by-deliverer`,
        {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          },
          body: {
            delivererId: user.id,
            hash: testHash
          }
        }
      );
      
      console.log(`✅ Confirmação bem-sucedida!`);
      console.log(`   - Status: ${confirmResponse.status}`);
      console.log(`   - Resposta:`, confirmResponse.data);
      
    } catch (error) {
      console.log(`❌ Erro na confirmação:`);
      console.log(`   - Status: ${error.response?.status}`);
      console.log(`   - Mensagem: ${error.response?.data?.message || error.message}`);
    }
    
    // 3. Testar com QR Code inválido
    console.log(`\n3. Testando com hash inválido...`);
    try {
      const invalidResponse = await makeRequest(
        `${baseUrl}/api/orders/${testOrderId}/confirm-delivery-by-deliverer`,
        {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          },
          body: {
            delivererId: user.id,
            hash: 'hash-invalido'
          }
        }
      );
      
      console.log(`   - Status: ${invalidResponse.status}`);
      console.log(`   - Resposta:`, invalidResponse.data);
      
    } catch (error) {
      console.log(`   - Status: ${error.response?.status} (esperado erro)`);
      console.log(`   - Mensagem: ${error.response?.data?.message || error.message}`);
    }
    
  } catch (error) {
    console.error('❌ Erro no teste:', error.message);
    if (error.response) {
      console.error('   - Status:', error.response.status);
      console.error('   - Data:', error.response.data);
    }
  }
}

// Executar teste
testFixedDeliveryConfirmation().then(() => {
  console.log('\n🏁 Teste concluído.');
}).catch(error => {
  console.error('❌ Erro fatal:', error);
});